import Foundation

public protocol StatbelService: ObservableObject {
    
    func getAllDatasources() async throws -> [Datasource]
    func getAllView() async throws -> [StatbelView]
    
}

public class StatbelServiceImpl: StatbelService {
    //private let apiUrl: String = "https://bestat.economie.fgov.be/bestat/api/"
    private let apiUrl: String = "http://localhost:8080/"
    
    private let jsonDecoder: JSONDecoder = JSONDecoder()
    private let urlSession = URLSession.shared
    
    public func getAllView() async throws -> [StatbelView] {
        guard let url = URL(string: apiUrl + "views/") else {
            return []
        }

        return try await self.get([StatbelView].self, url: url)
    }
    
    
    public func getAllDatasources() async throws -> [Datasource] {
        guard let url = URL(string: apiUrl + "datasources/") else {
            return []
        }
        
        return try await self.get([Datasource].self, url: url)
    }

    private func get<T: Decodable>(_ type: T.Type , url: URL) async throws -> T {
        let (data, res) = try await urlSession.data(from: url)
        
        guard let httpRes = res as? HTTPURLResponse, httpRes.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try jsonDecoder.decode(type, from: data)
    }
}
