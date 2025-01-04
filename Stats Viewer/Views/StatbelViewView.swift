import SwiftUI

struct StatbelViewView: View {
    
    @EnvironmentObject var statsbelService: StatbelService
    
    let statbelView: StatbelView
    @State var source: ExportResult? = nil
    
    @State private var selectedVisualizations: [VisualisationType] = []
    @State private var configs: [Configuration] = []
    
    @State private var showConfig: Bool = false
    @State private var configIndex: Int = 0
    
    
    init(statbelView: StatbelView) {
        self.statbelView = statbelView
    }
    
    func configBinding(index: Int) -> Binding<Configuration> {
        Binding(
            get: {
                self.configs[index]
            },
            set: {
                self.configs[index] = $0
            }
        )
    }
    
    func addVisualization(_ visualization: VisualisationType) {
        self.selectedVisualizations.append(visualization)
        self.configs.append(Configuration())
    }
    
    func removeVisualization(_ index: Int) {
        self.selectedVisualizations.remove(at: index)
        self.configs.remove(at: index)
    }
    
    func configFor() -> some View {
        let index = self.configIndex
        
        print(index)
        return self.selectedVisualizations[index].Config(
            source: self.source!,
            cfg: self.configBinding(index: index))
    }
    
    func getTitle(_ index: Int) -> String {
        let cfg: Configuration = self.configs[index]
        if cfg.title.isEmpty {
            return "Visualization \(index+1)"
        }
        
        return cfg.title
    }
    
    var configStack: some View {
        VStack {
            ScrollView {
                ForEach(self.selectedVisualizations.indices, id: \.self) { index in
                    HStack {
                        Text(self.getTitle(index))

                        Spacer()
                        
                        Button(action: {
                            self.configIndex = index
                            self.showConfig.toggle()
                        }) {
                            Image(systemName: "gear")
                                .foregroundColor(.blue)
                        }
                        .sheet(isPresented: $showConfig) {
                            self.configFor()
                        }
                        
                        Button(action: {
                            self.removeVisualization(index)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }.padding(10)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.gray.opacity(0.2), radius: 6, x: 0, y: 4)
                }
            }
        }.padding(10)
    }
    
    
    var optionsStack: some View {
        VStack {
            ScrollView {
                ForEach(VisualisationType.allCases, id: \.self) { vis in
                    HStack {
                        Text(vis.DisplayName())
                        Spacer()
                        Button(action: {
                            self.addVisualization(vis)
                        }) {
                            Text("Add")
                                .padding(8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .shadow(radius: 4)
                        }
                    }
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.gray.opacity(0.2), radius: 6, x: 0, y: 4)
                }
            }
        }.padding(10)
    }
    
    
    var renderButton: some View {
        NavigationLink(destination: RenderView(source: self.source!,
                                               visualisationTypes: self.selectedVisualizations,
                                               cfgs: self.configs)) {
            Text("Render")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if self.source != nil {
                    VStack {
                        Text(self.statbelView.name)
                            .font(.headline)
                        
                        optionsStack
                            .padding(.bottom, 8)
                        
                        configStack
                            .padding(.bottom, 8)
                        
                        renderButton
                    }
                    .padding(16)
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

// MARK: - Preview
struct StatbelViewView_Previews: PreviewProvider {
    static var previews: some View {
        StatbelViewView(statbelView: StatbelView(
            id: "1be9b77f-4005-4d58-a885-8281b5bbe617",
            name: "Densité de population (habitants/km²)",
            standard: true,
            dataSourceId: "e957ac31-44a2-4718-8469-10470d3c41d9",
            locale: "fr",
            lastChangeDate: 1713792548335,
            lastPublishDate: 1720687303859,
            note: "",
            published: true))
        .environmentObject(StatbelService())
    }
}
