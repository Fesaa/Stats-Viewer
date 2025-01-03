import SwiftUI
import Charts

class SimpleBarPlot: Visualisation {
    @State private var key: String = ""
    let source: ExportResult

    init(source: ExportResult) {
        self.source = source
    }

    private func keys() -> [String] {
        if self.source.facts.isEmpty {
            return []
        }
        return self.source.facts[0].keys.map { $0 }
    }

    private func mapData() -> Float? {
        return 0
    }

    func optionModels() -> AnyView {
        AnyView(NavigationView {
            Form {
                Section {
                    Picker("Key", selection: $key) {
                        ForEach(keys(), id: \.self) { key in
                            Text(key).tag(key)
                        }
                    }.onChange(of: key, initial: true) { newValue, _ in
                        self.key = newValue
                    }
                }
            }
        })
    }

    func visualisation() -> AnyView {
        AnyView(Chart {
            // Populate the chart as needed
        })
    }

    func isValid() -> Bool {
        return !key.isEmpty
    }

    func errors() -> [String] {
        return key.isEmpty ? ["Key cannot be empty"] : []
    }
}
