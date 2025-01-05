import SwiftUI
import Charts

struct SimpleBarPlot: View {
    var id: UUID = UUID()
    var source: ExportResult
    @State var config: Configuration
    @State var errors: [String] = []
    
    func transform(_ data: Fact) -> BarMark {
        let xKey = config.getValue("xKey") ?? self.source.facts[0].keys.first!
        let yKey = config.getValue("yKey") ?? self.source.facts[0].keys.first!

        let label = switch data[xKey]! {
        case .string(let s): s
        case .float(let f): String(f)
        case .none: ""
        }
        
        let value = switch data[yKey]! {
        case .string(_): Float(0)
        case .float(let f): f
        case .none: Float(0)
        }
        
        return BarMark(
            x: .value("Type", label),
            y: .value("Value", value)
        )
    }
    
    func marks(_ index: Int) -> BarMark {
        let fact = self.source.facts[index]
        return self.transform(fact)
    }
    
    var body: some View {
        Chart {
            ForEach(self.source.facts.indices, id: \.self) { index in
                self.marks(index)
            }
        }
    }
    
}

struct BarPlotConfigurationView: View {
    var source: ExportResult
    @Binding var cfg: Configuration
    @Binding var open: Bool
    @State private var showAlert = false
    
    private func keys() -> [String] {
        if self.source.facts.isEmpty {
                return []
            }
        return self.source.facts[0].keys.map { $0 }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Title") {
                    TextField("Title", text: $cfg.title)
                }
                Section("X Key") {
                    Picker("Key", selection: xKeyBinding()) {
                        ForEach(keys(), id: \.self) { key in
                            Text(key).tag(key)
                        }
                    }
                }
                
                Section("Y Key") {
                    Picker("Key", selection: yKeyBinding()) {
                        ForEach(keys(), id: \.self) { key in
                            Text(key).tag(key)
                        }
                    }
                }
                Button(action: {
                    let xKey = xKeyBinding().wrappedValue
                    let yKey = yKeyBinding().wrappedValue
                    
                    if xKey == yKey {
                        showAlert = true
                    } else {
                        self.open.toggle()
                    }
                }) {
                    Text("Close")
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                }.alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Invalid Keys"),
                        message: Text("X-Key and Y-Key must be different."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }
    
    func xKeyBinding() -> Binding<String> {
        Binding(
            get: {
                return self.cfg.getValue("xKey") ?? self.keys().first ?? ""
            },
            set: {
                self.cfg.setValue("xKey", value: $0)
            }
        )
    }
    
    func yKeyBinding() -> Binding<String> {
        Binding(
            get: {
                return self.cfg.getValue("yKey") ?? self.keys().first ?? ""
            },
            set: {
                self.cfg.setValue("yKey", value: $0)
            }
        )
    }

}
