import Foundation
import AtlasPolicy

struct AtlasNetworkResponse: Decodable {
    let envelope: AtlasSignedEnvelope
}

enum AtlasNetworkFailure: Error, LocalizedError {
    case invalidURL, httpCode(Int), oversizedResponse
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Неверный адрес учебного сервера"
        case .httpCode(let code): return "HTTP \(code)"
        case .oversizedResponse: return "Слишком большой ответ сервера"
        }
    }
}

struct AtlasNetworkClient {
    func fetchGrant(baseURL: String, profile: String, nonce: String) async throws -> AtlasSignedEnvelope {
        guard var url = URLComponents(string: baseURL.trimmingCharacters(in: .whitespacesAndNewlines)),
              let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme),
              url.host != nil else { throw AtlasNetworkFailure.invalidURL }
        url.path = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")) + "/v1/grant"
        if !url.path.hasPrefix("/") { url.path = "/" + url.path }
        url.queryItems = [URLQueryItem(name: "account_id", value: profile), URLQueryItem(name: "nonce", value: nonce)]
        guard let endpoint = url.url else { throw AtlasNetworkFailure.invalidURL }
        var request = URLRequest(url: endpoint)
        request.timeoutInterval = 8
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let result = response as? HTTPURLResponse else { throw AtlasNetworkFailure.invalidURL }
        guard (200...299).contains(result.statusCode) else { throw AtlasNetworkFailure.httpCode(result.statusCode) }
        guard data.count < 500_000 else { throw AtlasNetworkFailure.oversizedResponse }
        return try JSONDecoder().decode(AtlasNetworkResponse.self, from: data).envelope
    }
}
