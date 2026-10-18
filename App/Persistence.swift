import Foundation

final class AtlasVault {
    private let storage = UserDefaults.standard
    private let prefix = "atlas.lab.x."

    func loadSettings() -> AtlasSettings {
        guard let data = storage.data(forKey: prefix + "settings"),
              let value = try? JSONDecoder().decode(AtlasSettings.self, from: data) else {
            return AtlasSettings()
        }
        return value
    }
    func saveSettings(_ settings: AtlasSettings) {
        storage.set(try? JSONEncoder().encode(settings), forKey: prefix + "settings")
    }
    func loadIDs(_ key: String) -> Set<String> {
        Set(storage.stringArray(forKey: prefix + key) ?? [])
    }
    func saveIDs(_ value: Set<String>, key: String) {
        storage.set(Array(value).sorted(), forKey: prefix + key)
    }
    func loadCount(_ key: String) -> Int { storage.integer(forKey: prefix + key) }
    func addCount(_ key: String) { storage.set(loadCount(key) + 1, forKey: prefix + key) }
    func clear() {
        for key in ["settings", "saved", "completed", "opened", "denied"] { storage.removeObject(forKey: prefix + key) }
    }
}
