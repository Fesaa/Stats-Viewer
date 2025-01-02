import Foundation

public class StatbelService: ObservableObject {
    //private let apiUrl: String = "https://bestat.economie.fgov.be/bestat/api/"
    private let apiUrl: String = "http://localhost:8080/"
    
    private let jsonDecoder: JSONDecoder = JSONDecoder()
    private let urlSession = URLSession.shared
    
    private let cache: any CacheService = CacheServiceImpl.shared
    
    public func getExportResult(viewID: String, force: Bool = false) async throws -> ExportResult {
        if !force {
            let cachedExport = self.cache.retrieve(object: ExportResult.self, key: "views-export/\(viewID)")
            if (cachedExport != nil) {
                return cachedExport!
            }
        }
        
        guard let url = URL(string: apiUrl + "views/\(viewID)/result/JSON") else {
            throw URLError(.badURL)
        }
        
        return try await self.get(ExportResult.self, url: url)
    }
    
    public func getAllView(_ force: Bool = false) async throws -> [StatbelView] {
        if !force {
            let cachedViews = self.cache.retrieve(object: [StatbelView].self, key: "views")
            if (cachedViews != nil) {
                return cachedViews!
            }
        }
        
        guard let url = URL(string: apiUrl + "views/") else {
            return []
        }

        let views = try await self.get([StatbelView].self, url: url)
        do {
            try self.cache.store(object: views, key: "views")
        } catch {
            print("\(error)")
        }
        
        return views
    }

    private func get<T: Decodable>(_ type: T.Type , url: URL) async throws -> T {
        let (data, res) = try await urlSession.data(from: url)
        
        guard let httpRes = res as? HTTPURLResponse, httpRes.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try jsonDecoder.decode(type, from: data)
    }
}
