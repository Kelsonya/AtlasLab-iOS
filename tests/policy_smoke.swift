import Foundation

@main
struct PolicySmoke {
    static func main() {
        let all = Set(AtlasFeature.allCases)
        let expired = AtlasLocalSnapshot(tier: .pro, state: .active, expiresAt: 1704067199, rights: all, integrityOK: true, nativeTimeOK: false)
        let valid = AtlasLocalSnapshot(tier: .lifetime, state: .active, expiresAt: 4102444799, rights: all, integrityOK: true, nativeTimeOK: true)
        let rule = AtlasFeaturePolicy(feature: .studio, minimumTier: .pro, minimumRevision: 4, enabled: true, needsFreshLease: false)
        let book = AtlasRuleBook(version: 4, policies: [rule])
        let now: Int64 = 1792281600
        let localExpired = AtlasPolicyEngine.decide(feature: .studio, mode: .local, local: expired, signed: nil, book: book, now: now, proofError: nil)
        precondition(!localExpired.allowed)
        let localGood = AtlasPolicyEngine.decide(feature: .studio, mode: .local, local: valid, signed: nil, book: book, now: now, proofError: nil)
        precondition(localGood.allowed)
        let signed = AtlasGrant(accountID: "nova", tier: .lifetime, state: .active, issuedAt: now - 1, expiresAt: 4102444799, leaseUntil: now + 900, revision: 4, features: Array(all), nonce: "x")
        let hybridGood = AtlasPolicyEngine.decide(feature: .studio, mode: .hybrid, local: valid, signed: signed, book: book, now: now, proofError: nil)
        precondition(hybridGood.allowed)
        let hybridExpired = AtlasPolicyEngine.decide(feature: .studio, mode: .hybrid, local: expired, signed: signed, book: book, now: now, proofError: nil)
        precondition(!hybridExpired.allowed)
        let suspended = AtlasGrant(accountID: "quartz", tier: .pro, state: .suspended, issuedAt: now - 1, expiresAt: 4102444799, leaseUntil: now + 900, revision: 4, features: Array(all), nonce: "x")
        let signedBlocked = AtlasPolicyEngine.decide(feature: .studio, mode: .signed, local: valid, signed: suspended, book: book, now: now, proofError: nil)
        precondition(!signedBlocked.allowed)
        print("policy gate smoke tests OK")
    }
}
