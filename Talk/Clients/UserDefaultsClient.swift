import Foundation
 
enum UDKey: String {
    case appLanguage
    case appTheme
    case likedQuestions
    case subcategoryProgress
    case isPremium
}
 
struct UserDefaultsClient {
    private static let defaults = UserDefaults.standard
 
    static func set<T: Codable>(_ value: T, for key: UDKey) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key.rawValue)
        }
    }
 
    static func get<T: Codable>(_ type: T.Type, for key: UDKey) -> T? {
        guard let data = defaults.data(forKey: key.rawValue) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
 
    static func remove(_ key: UDKey) {
        defaults.removeObject(forKey: key.rawValue)
    }
}
