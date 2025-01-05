import SwiftUI

struct RenderView: View {
    @State var source: ExportResult
    @State var visualisationTypes: [VisualisationType]
    @State var cfgs: [Configuration]
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                if visualisationTypes.isEmpty {
                    VStack {
                        Text("No visualisations available")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                            .padding()
                        
                        Image(systemName: "tray")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    .padding()
                } else {
                    ForEach(self.visualisationTypes.indices, id: \.self) { index in
                        let cfg = self.cfgs[index]
                        let vis = self.visualisationTypes[index]
                        
                        VStack {
                            Text(cfg.title.isEmpty ? "Visualisation (\(index+1))" : cfg.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.bottom, 5)
                            
                            vis.Visuluatisation(source: self.source, cfg: cfg)
                        }
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .padding(.vertical, 5)
                    }
                }
            }
            .padding()
        }
    }
}
