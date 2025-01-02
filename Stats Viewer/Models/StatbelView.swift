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


public struct ExportResult: Codable {
    public let facts: [Dictionary<String, FactValue>]
}

public enum FactValue: Codable {
    case string(String)
    case float(Float)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let floatValue = try? container.decode(Float.self) {
            self = .float(floatValue)
        } else {
            throw DecodingError.typeMismatch(FactValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Value is not a String or Float"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let stringValue):
            try container.encode(stringValue)
        case .float(let floatValue):
            try container.encode(floatValue)
        }
    }
}

