import Foundation

public protocol StatsbelService {
    
    func getAllDatasources() async throws -> [Datasource]
    
}

public class StatsbelServiceImpl: StatsbelService {
    public static let shared: StatsbelService = StatsbelServiceImpl()
    
    private let apiUrl: String = "https://bestat.economie.fgov.be/bestat/api/"
    
    private let jsonDecoder: JSONDecoder = JSONDecoder()
    private let urlSession = URLSession.shared
    
    public func getAllDatasources() async throws -> [Datasource] {
        guard let url = URL(string: apiUrl + "datasources") else {
            return []
        }
        
        let (data, res) = try await urlSession.data(from: url)
        
        guard let httpRes = res as? HTTPURLResponse, httpRes.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try jsonDecoder.decode([Datasource].self, from: data)
    }
}
