import SwiftUI
import Charts

class SimpleBarPlot: BaseVisualisation {
    @State private var key: String = ""
    let source: ExportResult
    
    init(source: ExportResult) {
        self.source = source
    }
    
    private func keys() -> [String] {
        if (self.source.facts.count == 0) {
            return [];
        }
        
        return self.source.facts[0].keys.map { $0 }
    }
    
    private func mapData() -> Float? {
        return 0
    }
    
    override func optionModels() -> any View {
        NavigationView {
            Form {
                Section {
                    Picker("Key", selection: $key) {
                        ForEach(keys(), id: \.self) { key in
                            Text(key).tag(key)
                        }
                    }
                }
            }
        }
    }
    
    override func visualisation() -> any View {
        Chart {
        }
    }
    
    override func isValid() -> Bool {
        return !key.isEmpty
    }
    
    override func errors() -> [String] {
        return key.isEmpty ? ["Key cannot be empty"] : []
    }
}
