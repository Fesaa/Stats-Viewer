import SwiftUI

struct StatbelViewView: View {
    
    @EnvironmentObject var statsbelService: StatbelService
    
    let statbelView: StatbelView
    
    @State private var addedVisualisations: [(String, any Visualisation)] = []
    @State var source: ExportResult? = nil
    @State private var showingOptionsModal: AnyVisualisation? = nil
    
    var registry: Dictionary<String, (ExportResult) -> any Visualisation> {
        var r = Dictionary<String, (ExportResult) -> any Visualisation>();
        
        r["Simple Bar Plot"] = SimpleBarPlot.init;
        
        return r;
    }
    
    
    init(statbelView: StatbelView) {
        self.statbelView = statbelView
    }
    
    var optionsView: some View {
        VStack {
            Text("Available Visualisations")
                .font(.headline)
            
            ScrollView {
                ForEach(registry.keys.sorted(), id: \.self) { visualisationName in
                    HStack {
                        Text(visualisationName)
                        Spacer()
                        Button(action: {
                            if let exportResult = source, let createVisualisation = registry[visualisationName] {
                                let visualisation = createVisualisation(exportResult)
                                addedVisualisations.append((visualisationName, visualisation))
                            }
                        }) {
                            Text("Add")
                                .padding(5)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(5)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    var currentVisualisationsView: some View {
        
        VStack {
            Text("Added Visualisations")
                .font(.headline)
            
            ScrollView {
                ForEach(addedVisualisations.indices, id: \.self) { index in
                    let (name, visualisation) = addedVisualisations[index]
                    HStack {
                        Text(name)
                        
                        Spacer()
                        
                        Button(action: {
                            showingOptionsModal = AnyVisualisation(visualisation)
                        }) {
                            Image(systemName: "gear")
                                .foregroundColor(.blue)
                        }
                        .sheet(item: $showingOptionsModal) { vis in
                            vis.optionModels()
                        }
                        
                        Button(action: {
                            addedVisualisations.remove(at: index)
                        }) {
                            Text("Remove")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    var renderButton: some View {
        Button(action: {
            print("Rendering...")
        }) {
            Text("Render")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }
    
    var body: some View {
        NavigationView {
            Group {
                if self.source != nil {
                    VStack {
                        Text(self.statbelView.name)
                        
                        optionsView
                        currentVisualisationsView
                        renderButton
                    }
                } else {
                    VStack {
                        LoadingView()
                    }
                }
            }
            .task {
                do {
                    self.source = try await self.statsbelService.getExportResult(viewID: self.statbelView.id)
                } catch {
                    print("\(error)")
                }
            }
        }
    }
}
