import Foundation
import CryptoKit

public struct AtlasLedgerEntry: Codable, Identifiable {
    public let id: UUID
    public let timestamp: Date
    public let action: String
    public let detail: String
    public let previousDigest: String
    public let digest: String
}

public final class AtlasAuditLedger {
    private(set) public var entries: [AtlasLedgerEntry] = []
    public init() {}

    @discardableResult
    public func append(action: String, detail: String) -> AtlasLedgerEntry {
        let previous = entries.last?.digest ?? String(repeating: "0", count: 64)
        let stamp = Date()
        let id = UUID()
        let canonical = "\(previous)|\(id.uuidString)|\(Int(stamp.timeIntervalSince1970))|\(action)|\(detail)"
        let digest = Self.digest(canonical)
        let entry = AtlasLedgerEntry(id: id, timestamp: stamp, action: action, detail: detail, previousDigest: previous, digest: digest)
        entries.append(entry)
        if entries.count > 200 { entries.removeFirst(entries.count - 200) }
        return entry
    }

    public func verify() -> Bool {
        var previous = entries.first?.previousDigest ?? String(repeating: "0", count: 64)
        for entry in entries {
            guard entry.previousDigest == previous else { return false }
            let canonical = "\(previous)|\(entry.id.uuidString)|\(Int(entry.timestamp.timeIntervalSince1970))|\(entry.action)|\(entry.detail)"
            guard Self.digest(canonical) == entry.digest else { return false }
            previous = entry.digest
        }
        return true
    }

    private static func digest(_ value: String) -> String {
        SHA256.hash(data: Data(value.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}

public struct AtlasTextMetrics {
    public let characters: Int
    public let words: Int
    public let sentences: Int
    public let uniqueWords: Int
    public let topTerms: [(String, Int)]
    public let diversity: Double
}

public enum AtlasTextAnalyzer {
    public static func analyze(_ input: String) -> AtlasTextMetrics {
        let parts = input.lowercased().split(whereSeparator: { !$0.isLetter && !$0.isNumber })
        let words = parts.map(String.init).filter { $0.count >= 2 }
        var frequencies: [String: Int] = [:]
        for word in words { frequencies[word, default: 0] += 1 }
        let sentences = max(1, input.filter { ".!?".contains($0) }.count)
        let popular = frequencies.sorted { $0.value == $1.value ? $0.key < $1.key : $0.value > $1.value }.prefix(8).map { ($0.key, $0.value) }
        return AtlasTextMetrics(characters: input.count, words: words.count, sentences: sentences, uniqueWords: frequencies.count, topTerms: popular, diversity: words.isEmpty ? 0 : Double(frequencies.count) / Double(words.count))
    }
}
