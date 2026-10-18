import Foundation
import CryptoKit

public enum AtlasProofError: Error, LocalizedError {
    case invalidBase64, invalidKey, invalidSignature, invalidPayload
    case wrongAccount, wrongNonce, futureIssue, expiredLease
    public var errorDescription: String? {
        switch self {
        case .invalidBase64: return "Неверная Base64-кодировка ответа"
        case .invalidKey: return "Недействительный открытый ключ"
        case .invalidSignature: return "Подпись не прошла проверку Ed25519"
        case .invalidPayload: return "Неверный формат подтверждения"
        case .wrongAccount: return "Подтверждение выдано другому аккаунту"
        case .wrongNonce: return "Ответ относится к другому запросу"
        case .futureIssue: return "Дата выдачи подтверждения находится в будущем"
        case .expiredLease: return "Срок серверного подтверждения истёк"
        }
    }
}

public enum AtlasProofVerifier {
    public static func verify(_ envelope: AtlasSignedEnvelope, publicKeyBase64: String, accountID: String, nonce: String?, now: Int64) throws -> AtlasGrant {
        guard let keyBytes = Data(base64Encoded: publicKeyBase64) else { throw AtlasProofError.invalidKey }
        let publicKey: Curve25519.Signing.PublicKey
        do { publicKey = try Curve25519.Signing.PublicKey(rawRepresentation: keyBytes) }
        catch { throw AtlasProofError.invalidKey }
        guard let payload = Data(base64Encoded: envelope.payload), let signature = Data(base64Encoded: envelope.signature) else {
            throw AtlasProofError.invalidBase64
        }
        guard publicKey.isValidSignature(signature, for: payload) else { throw AtlasProofError.invalidSignature }
        guard let grant = try? JSONDecoder().decode(AtlasGrant.self, from: payload) else {
            throw AtlasProofError.invalidPayload
        }
        guard grant.accountID == accountID else { throw AtlasProofError.wrongAccount }
        if let nonce = nonce, grant.nonce != nonce { throw AtlasProofError.wrongNonce }
        if grant.issuedAt > now + 300 { throw AtlasProofError.futureIssue }
        if grant.leaseUntil <= now { throw AtlasProofError.expiredLease }
        return grant
    }
}
