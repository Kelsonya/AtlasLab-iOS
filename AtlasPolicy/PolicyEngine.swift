import Foundation

public enum AtlasPolicyEngine {
    public static func decide(feature: AtlasFeature, mode: AtlasEvaluationMode, local: AtlasLocalSnapshot, signed: AtlasGrant?, book: AtlasRuleBook, now: Int64, proofError: String?) -> AtlasGateResult {
        guard let rule = book.policy(for: feature) else {
            return AtlasGateResult(feature: feature, allowed: false, reasons: ["Политика для функции не определена"], source: mode.rawValue, expiresAt: nil)
        }
        var reasons: [String] = []
        if !rule.enabled { reasons.append("Функция отключена в политике") }

        if mode == .local || mode == .hybrid {
            if !local.integrityOK { reasons.append("Целостность локального состояния не подтверждена") }
            if !local.nativeTimeOK { reasons.append("Нативный C-проверяющий отклонил дату или статус") }
            if local.state != .active { reasons.append("Локальный аккаунт заблокирован") }
            if now >= local.expiresAt { reasons.append("Локальная дата доступа истекла") }
            if local.tier.rank < rule.minimumTier.rank { reasons.append("Недостаточный локальный тариф") }
            if !local.rights.contains(feature) { reasons.append("Локальная маска прав запрещает функцию") }
        }
        if mode == .signed || mode == .hybrid {
            guard let signed = signed else {
                reasons.append(proofError ?? "Нет проверенного серверного подтверждения")
                return AtlasGateResult(feature: feature, allowed: false, reasons: reasons, source: mode.rawValue, expiresAt: nil)
            }
            if signed.state != .active { reasons.append("Серверный статус аккаунта неактивен") }
            if now >= signed.expiresAt { reasons.append("Серверная дата подписки истекла") }
            if signed.tier.rank < rule.minimumTier.rank { reasons.append("Недостаточный серверный тариф") }
            if signed.revision < rule.minimumRevision { reasons.append("Версия политики устарела") }
            if !signed.features.contains(feature) { reasons.append("Сервер не выдал право на функцию") }
            if rule.needsFreshLease && signed.leaseUntil <= now + 30 { reasons.append("Для этой функции нужен свежий lease") }
        }
        return AtlasGateResult(feature: feature, allowed: reasons.isEmpty, reasons: reasons.isEmpty ? ["Все проверки пройдены"] : reasons, source: mode.rawValue, expiresAt: (mode == .local ? local.expiresAt : signed?.expiresAt))
    }
}
