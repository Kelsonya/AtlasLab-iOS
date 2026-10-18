import Foundation
import Combine

private struct SimulatedServerFixture: Decodable {
    let active: Bool
    let planCode: Int
    let expiresAt: String
    let source: String
    let message: String
}

private enum LicenseEvaluator {
    static func evaluate(account: LabAccount, mode: LicenseMode, now: Date) -> LicenseSnapshot {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]
        let profileOK = account.accountEnabled == 1
        let tierOK = account.planCode == 2

        if mode == .local {
            // Calls native C functions; deliberately chosen for clear ARM64 analysis.
            let rawExpiry = String(cString: lab_license_seed_expiry())
            let parsedExpiry = iso.date(from: rawExpiry)
            let timeOK = parsedExpiry.map { $0 > now } ?? false
            let localAccess = lab_has_local_entitlement(
                account.accountEnabled, account.planCode,
                Int64(parsedExpiry?.timeIntervalSince1970 ?? 0),
                Int64(now.timeIntervalSince1970)
            ) != 0
            return LicenseSnapshot(
                accessGranted: localAccess,
                expiryText: rawExpiry,
                sourceDescription: "Проверка в Mach-O через LicenseCore.c (не App Store)",
                checks: [
                    LicenseCheck(id: "account", passed: profileOK, explanation: "Аккаунт разрешён"),
                    LicenseCheck(id: "tier", passed: tierOK, explanation: "Тариф PRO (код 2)"),
                    LicenseCheck(id: "date", passed: timeOK, explanation: "Дата окончания позже текущей"),
                    LicenseCheck(id: "native", passed: localAccess, explanation: "Итог нативной проверки C")
                ]
            )
        }

        // This is deliberately NOT a real HTTP server. The response is a bundled JSON
        // fixture that shows why patching the LOCAL seed alone cannot affect another source.
        guard let url = Bundle.main.url(forResource: "RemoteFixture", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let reply = try? JSONDecoder().decode(SimulatedServerFixture.self, from: data) else {
            return LicenseSnapshot(accessGranted: false, expiryText: "Ошибка загрузки",
                sourceDescription: "Нет учебного JSON-ответа",
                checks: [LicenseCheck(id: "fixture", passed: false, explanation: "RemoteFixture.json не найден")])
        }
        let fixtureTimeOK = (iso.date(from: reply.expiresAt) ?? .distantPast) > now
        let fixtureTierOK = reply.planCode == 2
        let allowed = profileOK && tierOK && reply.active && fixtureTierOK && fixtureTimeOK
        return LicenseSnapshot(
            accessGranted: allowed,
            expiryText: reply.expiresAt,
            sourceDescription: "\(reply.source): \(reply.message)",
            checks: [
                LicenseCheck(id: "account", passed: profileOK, explanation: "Локальный профиль разрешён"),
                LicenseCheck(id: "tier", passed: tierOK, explanation: "Локальный тариф PRO"),
                LicenseCheck(id: "serverActive", passed: reply.active, explanation: "Флаг active в учебном JSON"),
                LicenseCheck(id: "serverTier", passed: fixtureTierOK, explanation: "PRO в учебном JSON"),
                LicenseCheck(id: "serverExpiry", passed: fixtureTimeOK, explanation: "Срок в учебном JSON не истёк")
            ]
        )
    }
}

@MainActor
final class LicenseManager: ObservableObject {
    @Published var account: LabAccount = .expiredPro { didSet { refresh() } }
    @Published var mode: LicenseMode = .local { didSet { refresh() } }
    @Published private(set) var snapshot: LicenseSnapshot

    init() {
        snapshot = LicenseEvaluator.evaluate(account: .expiredPro, mode: .local, now: Date())
    }

    func refresh() {
        snapshot = LicenseEvaluator.evaluate(account: account, mode: mode, now: Date())
    }
}
