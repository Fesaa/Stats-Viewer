import Foundation

public protocol CacheService: ObservableObject {
    func store<T: Codable>(object: T, key: String) throws
    func retrieve<T: Codable>(object: T.Type, key: String) -> T?
    func delete(key: String) throws
}

public class CacheServiceImpl: CacheService {
    static let shared = CacheServiceImpl()
    
    private struct CacheEntry<T: Codable>: Codable {
        let object: T
        let storageDate: Date
    }
    
    private let cacheDirectory: URL
    
    public init() {
        let cacheDirectoryName = "art.ameliah.ehb.ios.statsviewer.cache"
        guard let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(cacheDirectoryName) else {
            fatalError("Unable to locate cache directory.")
        }
        cacheDirectory = directory
    }
    
    public func store<T: Codable>(object: T, key: String) throws {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        let cacheEntry = CacheEntry(object: object, storageDate: Date())

        let directoryURL = fileURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        let data = try JSONEncoder().encode(cacheEntry)
        try data.write(to: fileURL)
    }
    
    public func retrieve<T: Codable>(object: T.Type, key: String) -> T? {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        
        do {
            let data = try Data(contentsOf: fileURL)
            let cacheEntry = try JSONDecoder().decode(CacheEntry<T>.self, from: data)
            return cacheEntry.object
        } catch {
            return nil
        }
    }

    
    public func delete(key: String) throws {
        let fileManager = FileManager.default
        let fileURL = cacheDirectory.appendingPathComponent(key)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }
}
