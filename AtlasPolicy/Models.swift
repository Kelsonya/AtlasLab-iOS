import Foundation

public enum AtlasTier: String, Codable, CaseIterable, Identifiable {
    case basic, plus, pro, lifetime
    public var id: String { rawValue }
    public var rank: Int {
        switch self { case .basic: return 0; case .plus: return 1; case .pro: return 2; case .lifetime: return 3 }
    }
    public var displayName: String { rawValue.capitalized }
}

public enum AtlasFeature: String, Codable, CaseIterable, Identifiable {
    case reading, bookmarks, deepDive, studio, insights, exporting, offlineCache, laboratory
    public var id: String { rawValue }
    public var title: String {
        switch self {
        case .reading: return "Чтение"
        case .bookmarks: return "Закладки"
        case .deepDive: return "Полные разборы"
        case .studio: return "Исследовательская студия"
        case .insights: return "Аналитика"
        case .exporting: return "Экспорт"
        case .offlineCache: return "Офлайн-хранилище"
        case .laboratory: return "Лаборатория"
        }
    }
}

public enum AtlasAccountState: String, Codable { case active, suspended, underReview }

public enum AtlasEvaluationMode: String, CaseIterable, Identifiable {
    case local, signed, hybrid
    public var id: String { rawValue }
    public var label: String {
        switch self {
        case .local: return "Локальная"
        case .signed: return "Подписанный сервер"
        case .hybrid: return "Комбинированная"
        }
    }
}

public struct AtlasGrant: Codable {
    public let accountID: String
    public let tier: AtlasTier
    public let state: AtlasAccountState
    public let issuedAt: Int64
    public let expiresAt: Int64
    public let leaseUntil: Int64
    public let revision: Int
    public let features: [AtlasFeature]
    public let nonce: String
    public init(accountID: String, tier: AtlasTier, state: AtlasAccountState, issuedAt: Int64, expiresAt: Int64, leaseUntil: Int64, revision: Int, features: [AtlasFeature], nonce: String) {
        self.accountID = accountID; self.tier = tier; self.state = state
        self.issuedAt = issuedAt; self.expiresAt = expiresAt; self.leaseUntil = leaseUntil
        self.revision = revision; self.features = features; self.nonce = nonce
    }
}

public struct AtlasSignedEnvelope: Codable {
    public let payload: String
    public let signature: String
    public init(payload: String, signature: String) { self.payload = payload; self.signature = signature }
}

public struct AtlasLocalSnapshot {
    public let tier: AtlasTier
    public let state: AtlasAccountState
    public let expiresAt: Int64
    public let rights: Set<AtlasFeature>
    public let integrityOK: Bool
    public let nativeTimeOK: Bool
    public init(tier: AtlasTier, state: AtlasAccountState, expiresAt: Int64, rights: Set<AtlasFeature>, integrityOK: Bool, nativeTimeOK: Bool) {
        self.tier = tier; self.state = state; self.expiresAt = expiresAt
        self.rights = rights; self.integrityOK = integrityOK; self.nativeTimeOK = nativeTimeOK
    }
}

public struct AtlasFeaturePolicy: Codable {
    public let feature: AtlasFeature
    public let minimumTier: AtlasTier
    public let minimumRevision: Int
    public let enabled: Bool
    public let needsFreshLease: Bool
    public init(feature: AtlasFeature, minimumTier: AtlasTier, minimumRevision: Int, enabled: Bool, needsFreshLease: Bool) {
        self.feature = feature; self.minimumTier = minimumTier
        self.minimumRevision = minimumRevision; self.enabled = enabled
        self.needsFreshLease = needsFreshLease
    }
}

public struct AtlasRuleBook: Codable {
    public let version: Int
    public let policies: [AtlasFeaturePolicy]
    public init(version: Int, policies: [AtlasFeaturePolicy]) {
        self.version = version
        self.policies = policies
    }

    public func policy(for feature: AtlasFeature) -> AtlasFeaturePolicy? {
        policies.first(where: { $0.feature == feature })
    }
}

public struct AtlasGateResult {
    public let feature: AtlasFeature
    public let allowed: Bool
    public let reasons: [String]
    public let source: String
    public let expiresAt: Int64?
    public init(feature: AtlasFeature, allowed: Bool, reasons: [String], source: String, expiresAt: Int64?) {
        self.feature = feature; self.allowed = allowed; self.reasons = reasons
        self.source = source; self.expiresAt = expiresAt
    }
}
