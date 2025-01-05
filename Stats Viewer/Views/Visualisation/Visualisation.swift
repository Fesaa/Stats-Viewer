import Foundation
import SwiftUI

enum VisualisationType: CaseIterable {
    
    case BarPlot
    case Table
    case Map
    //case LinePlot
    
    func DisplayName() -> String {
        switch self {
        case .BarPlot: return "Bar Plot"
        case .Table: return "Table"
        case .Map: return "Map"
        //case .LinePlot: return "Line Plot"
        }
    }
    
    func Config(source: ExportResult, cfg: Binding<Configuration>, open: Binding<Bool>) -> some View {
        switch self {
        case .BarPlot: return AnyView(BarPlotConfigurationView(source: source, cfg: cfg, open: open))
        case .Table: return AnyView(TableConfigurationView(source: source, cfg: cfg, open: open))
        case .Map: return AnyView(MapViewConfiguration(source: source, cfg: cfg, open: open))
        }
    }
    
    func Visuluatisation(source: ExportResult, cfg: Configuration) -> some View {
        switch self {
        case .BarPlot: return AnyView(SimpleBarPlot(source: source, config: cfg))
        case .Table: return AnyView(TableView(source: source, config: cfg))
        case .Map: return AnyView(MapView(source: source, config: cfg))
        }
    }
}

struct Configuration {
    var title: String = ""
    private var values: Dictionary<String, [String]> = [:]
    
    mutating func setValue(_ key: String, value: String) {
        self.values[key] = [value]
    }
    
    func getValue(_ key: String) -> String? {
        let values = self.values[key] ?? []
        return values.first
    }
    
    mutating func setValues(_ key: String, values: [String]) {
        self.values[key] = values
    }
    
    mutating func addValue(_ key: String, value: String) {
        if self.values[key] == nil {
            self.values[key] = [value]
        } else {
            self.values[key]?.append(value)
        }
    }
    
    func getValues(_ key: String) -> [String] {
        return self.values[key] ?? []
    }
}

struct Visualization: Identifiable {
    var id: UUID = UUID()
    var render: any View
    var config: any View
}
