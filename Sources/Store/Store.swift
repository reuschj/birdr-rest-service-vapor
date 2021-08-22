import Foundation

/// This will substitute for a database until that's available
public class Store {
    private var internalStorage: [String: Any?] = [:]

    public init() {
        self.internalStorage = [:]
    }

    public func set<Type>(_ value: Type, withKey key: String? = nil) -> String {
        let storageKey = key ?? UUID().uuidString
        internalStorage[storageKey] = value
        return storageKey
    }

    public func get<Type>(fromKey key: String) -> Type? {
        guard let value = internalStorage[key] as? Type else { return nil }
        return value
    }

    public func get<Type>(fromKey key: String, or fallback: Type) -> Type {
        guard let value = internalStorage[key] as? Type else { return fallback }
        return value
    }

    public static let shared: Store = Store()
}
