import Foundation
import SwiftUI
import AtlasPolicy
import AtlasSignals

@MainActor
final class AtlasCoordinator: ObservableObject {
    @Published private(set) var articles: [AtlasArticle] = []
    @Published private(set) var profiles: [AtlasProfile] = []
    @Published private(set) var decisions: [AtlasFeature: AtlasGateResult] = [:]
    @Published private(set) var saved: Set<String> = []
    @Published private(set) var completed: Set<String> = []
    @Published private(set) var openedCount = 0
    @Published private(set) var deniedCount = 0
    @Published private(set) var busy = false
    @Published private(set) var statusLine = "Подготовка проверок…"
    @Published private(set) var verifiedGrant: AtlasGrant?
    @Published private(set) var serverProofError: String?
    @Published private(set) var settings: AtlasSettings
    @Published private(set) var audit: [AtlasLedgerEntry] = []

    let policyBook: AtlasRuleBook
    private let fixtures: AtlasFixtureBundle?
    private let vault = AtlasVault()
    private let ledger = AtlasAuditLedger()
    private let network = AtlasNetworkClient()

    init() {
        policyBook = AtlasResourceLoader.decode("FeaturePolicies", as: AtlasRuleBook.self) ?? AtlasRuleBook(version: 0, policies: [])
        fixtures = AtlasResourceLoader.decode("SignedFixtures", as: AtlasFixtureBundle.self)
        articles = AtlasResourceLoader.decode("Articles", as: [AtlasArticle].self) ?? []
        profiles = AtlasResourceLoader.decode("Profiles", as: [AtlasProfile].self) ?? []
        settings = vault.loadSettings()
        saved = vault.loadIDs("saved")
        completed = vault.loadIDs("completed")
        openedCount = vault.loadCount("opened")
        deniedCount = vault.loadCount("denied")
        ledger.append(action: "boot", detail: "Atlas Lab X started")
        audit = ledger.entries.reversed()
        refreshLocalDecisions()
    }

    var selectedProfile: AtlasProfile? { profiles.first { $0.id == settings.profileID } }
    var mode: AtlasEvaluationMode { AtlasEvaluationMode(rawValue: settings.modeName) ?? .hybrid }
    var isProofHealthy: Bool { verifiedGrant != nil && serverProofError == nil }
    var ledgerValid: Bool { ledger.verify() }
    var accountSummary: String { selectedProfile?.displayName ?? settings.profileID }
    var now: Int64 { Int64(Date().timeIntervalSince1970) }

    var localGrant: ALGrant { al_grant_for_profile(settings.profileID) }
    var localSnapshot: AtlasLocalSnapshot {
        let grant = localGrant
        let tier: AtlasTier
        switch grant.tier { case 1: tier = .plus; case 2: tier = .pro; case 3: tier = .lifetime; default: tier = .basic }
        var mutable = grant
        let rights = Set(AtlasFeature.allCases.filter { al_check_feature(&mutable, $0.bit) != 0 })
        return AtlasLocalSnapshot(tier: tier, state: (grant.flags & 1) == 0 ? .active : .suspended, expiresAt: Int64(grant.expiration), rights: rights, integrityOK: al_integrity(&mutable) != 0, nativeTimeOK: al_check_expiry(&mutable, UInt64(max(now, 0))) != 0)
    }

    var diagnostics: [(String, String)] {
        var native = localGrant
        return [
            ("Профиль", settings.profileID),
            ("Режим", mode.label),
            ("Локальный срок", formatEpoch(Int64(native.expiration))),
            ("Локальный тариф", localSnapshot.tier.displayName),
            ("Нативная маска прав", String(format: "0x%08X", native.feature_bits)),
            ("Печать состояния", String(format: "%08X", native.seal)),
            ("Отпечаток gate", String(format: "%08X", al_gate_fingerprint(&native))),
            ("Политика", "v\(policyBook.version)"),
            ("Подтверждение", isProofHealthy ? "Подпись проверена" : (serverProofError ?? "Ожидает проверки")),
            ("Срок подтверждения", verifiedGrant.map { formatEpoch($0.expiresAt) } ?? "—"),
            ("Целостность журнала", ledgerValid ? "OK" : "FAILED")
        ]
    }

    private func formatEpoch(_ value: Int64) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss 'UTC'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: Date(timeIntervalSince1970: TimeInterval(value)))
    }

    func updateProfile(_ id: String) {
        var new = settings; new.profileID = id; settings = new; vault.saveSettings(new)
        verifiedGrant = nil; serverProofError = nil
        record("profile", id)
        refreshLocalDecisions()
        Task { await refreshProof() }
    }
    func updateMode(_ mode: AtlasEvaluationMode) {
        var new = settings; new.modeName = mode.rawValue; settings = new; vault.saveSettings(new)
        record("mode", mode.rawValue)
        refreshLocalDecisions()
        if mode != .local { Task { await refreshProof() } }
    }
    func updateServerURL(_ url: String) {
        var new = settings; new.serverURL = url; settings = new; vault.saveSettings(new)
    }

    func refreshLocalDecisions() {
        let snapshot = localSnapshot
        var new: [AtlasFeature: AtlasGateResult] = [:]
        for feature in AtlasFeature.allCases {
            new[feature] = AtlasPolicyEngine.decide(feature: feature, mode: mode, local: snapshot, signed: verifiedGrant, book: policyBook, now: now, proofError: serverProofError)
        }
        decisions = new
    }

    func refreshProof() async {
        guard !busy else { return }
        busy = true
        defer { busy = false }
        let profile = settings.profileID
        var freshGrant: AtlasGrant?
        var errorText: String?
        do {
            guard let fixtures = fixtures else { throw AtlasProofError.invalidPayload }
            let envelope: AtlasSignedEnvelope
            let nonce: String?
            if !settings.serverURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let freshNonce = UUID().uuidString
                envelope = try await network.fetchGrant(baseURL: settings.serverURL, profile: profile, nonce: freshNonce)
                nonce = freshNonce
            } else {
                guard let fixture = fixtures.grants[profile] else { throw AtlasProofError.invalidPayload }
                envelope = fixture
                nonce = "fixture"
            }
            freshGrant = try AtlasProofVerifier.verify(envelope, publicKeyBase64: fixtures.publicKey, accountID: profile, nonce: nonce, now: now)
            statusLine = settings.serverURL.isEmpty ? "Подписанный демонстрационный ответ" : "Ответ получен от учебного сервера"
        } catch {
            errorText = error.localizedDescription
            statusLine = "Ошибка подтверждения: \(error.localizedDescription)"
        }
        if profile == settings.profileID {
            verifiedGrant = freshGrant
            serverProofError = errorText
            refreshLocalDecisions()
            record("proof", freshGrant == nil ? (errorText ?? "unknown") : "verified")
        }
    }

    func can(_ feature: AtlasFeature) -> Bool { decisions[feature]?.allowed == true }
    func reasons(_ feature: AtlasFeature) -> [String] { decisions[feature]?.reasons ?? ["Проверка не проводилась"] }

    @discardableResult
    func enter(_ article: AtlasArticle) -> Bool {
        refreshLocalDecisions()
        let allowed = can(article.feature)
        if allowed {
            vault.addCount("opened")
            openedCount += 1
            record("open", article.id)
        } else {
            vault.addCount("denied")
            deniedCount += 1
            record("deny", "\(article.id):\(article.feature.rawValue)")
        }
        return allowed
    }
    func toggleSaved(_ id: String) {
        if saved.contains(id) { saved.remove(id) } else { saved.insert(id) }
        vault.saveIDs(saved, key: "saved")
        record("bookmark", id)
    }
    func markCompleted(_ id: String) {
        completed.insert(id); vault.saveIDs(completed, key: "completed")
        record("completed", id)
    }
    func record(_ action: String, _ detail: String) {
        ledger.append(action: action, detail: detail)
        audit = ledger.entries.reversed()
    }
    func reset() {
        vault.clear()
        settings = AtlasSettings(); vault.saveSettings(settings)
        saved.removeAll(); completed.removeAll(); openedCount = 0; deniedCount = 0
        verifiedGrant = nil; serverProofError = nil
        record("reset", "demo storage cleared")
        refreshLocalDecisions()
    }
}
