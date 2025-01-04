import Foundation
import SwiftUI

enum VisualisationType: CaseIterable {
    
    case BarPlot
    //case LinePlot
    
    func DisplayName() -> String {
        switch self {
        case .BarPlot: return "Bar Plot"
        //case .LinePlot: return "Line Plot"
        }
    }
    
    func Config(source: ExportResult, cfg: Binding<Configuration>) -> some View {
        switch self {
        case .BarPlot: return BarPlotConfigurationView(source: source, cfg: cfg)
        }
    }
    
    func Visuluatisation(source: ExportResult, cfg: Configuration) -> some View {
        switch self {
        case .BarPlot: return SimpleBarPlot(source: source, config: cfg)
        }
    }
}

struct Configuration {
    var title: String = ""
    var values: Dictionary<String, String> = [:]
}

struct Visualization: Identifiable {
    var id: UUID = UUID()
    var render: any View
    var config: any View
}
