import Foundation
import AtlasPolicy

struct AtlasArticle: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let category: String
    let summary: String
    let body: String
    let minutes: Int
    let symbol: String
    let feature: AtlasFeature
}

struct AtlasProfile: Identifiable, Codable, Hashable {
    let id: String
    let displayName: String
    let caption: String
}

struct AtlasSettings: Codable {
    var profileID: String = "orion"
    var modeName: String = "hybrid"
    var serverURL: String = ""
    var preferredTheme: Int = 0
}

enum AtlasResourceLoader {
    static func decode<T: Decodable>(_ name: String, as type: T.Type) -> T? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}

struct AtlasFixtureBundle: Codable {
    let publicKey: String
    let grants: [String: AtlasSignedEnvelope]
}

extension AtlasFeature {
    var icon: String {
        switch self {
        case .reading: return "book"
        case .bookmarks: return "bookmark"
        case .deepDive: return "text.book.closed"
        case .studio: return "wand.and.stars"
        case .insights: return "chart.bar.xaxis"
        case .exporting: return "square.and.arrow.up"
        case .offlineCache: return "externaldrive"
        case .laboratory: return "wrench.and.screwdriver"
        }
    }
    var bit: UInt32 {
        guard let index = Self.allCases.firstIndex(of: self) else { return 0 }
        return UInt32(1) << UInt32(index)
    }
}
