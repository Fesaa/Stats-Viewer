public struct Datasource: Codable, Identifiable {
    
    public let id: String
    public let `internal`: Bool
    public let fullySummarized: Bool
    public let lastDataUpdateDate: Int64
    public let lastPublishDate: Int64
    public let lastMetadataDataUpdateDate: Int64
    public let published: Bool
    
    public let defaultLocale: Locale
    
    public let name: String
    public let category: String
    
    public let supportedLocales: [String]
    public let descriptions: [String: String]
    public let metadataFilenames: [String: String?]
    
}

public enum Locale: String, Codable {
    case DE = "de"
    case EN = "en"
    case FR = "fr"
    case NL = "nl"
}


