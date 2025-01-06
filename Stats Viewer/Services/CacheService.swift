import Foundation

public class CacheService: ObservableObject {
    static let shared = CacheService()
    
    private struct CacheEntry<T: Codable>: Codable {
        let object: T
        let storageDate: Date
    }
    
    private struct SimplifiedCacheEntry: Decodable {
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
    
    public func age(_ key: String) throws -> Date? {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        
        do {
            let data = try Data(contentsOf: fileURL)
            let cacheEntry = try JSONDecoder().decode(SimplifiedCacheEntry.self, from: data)
            return cacheEntry.storageDate
        } catch let error as NSError where error.domain == NSCocoaErrorDomain && error.code == NSFileReadNoSuchFileError {
            return nil
        } catch {
            throw error
        }
    }

    
    public func listAllKeysAndDates() throws -> [(key: String, date: Date)] {
        let fileManager = FileManager.default
        let fileURLs = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        
        var result: [(key: String, date: Date)] = []
        
        for fileURL in fileURLs {
            let key = fileURL.lastPathComponent
            if let date = try? age(key) {
                result.append((key: key, date: date))
            }
        }
        
        return result
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
            
            if cacheEntry.storageDate < Date().addingTimeInterval(-60 * 60 * 24) {
                try delete(key: key)
                return nil
            }
            
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
