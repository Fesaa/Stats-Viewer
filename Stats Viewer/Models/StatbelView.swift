import Foundation

public struct StatbelView: Codable, Identifiable {
    
    public let id: String
    public let name: String
    public let standard: Bool
    public let dataSourceId: String
    public let locale: String
    
    public let lastChangeDate: Int64
    public let lastPublishDate: Int64
    
    public let note: String?
    public let published: Bool
    
    public func getLastChangeDate() -> Date {
        Date(timeIntervalSince1970: TimeInterval(lastChangeDate)/1000)
    }
    
}
