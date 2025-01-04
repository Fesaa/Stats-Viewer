import SwiftUI

struct RenderView: View {
    @State var source: ExportResult
    @State var visualisationTypes: [VisualisationType]
    @State var cfgs: [Configuration]
    
    var body: some View {
        
        ScrollView(.vertical) {
            VStack {
                ForEach(self.visualisationTypes.indices, id: \.self) { index in
                    let cfg = self.cfgs[index]
                    let vis = self.visualisationTypes[index]
                    
                    VStack {
                        Text(cfg.title)
                            .font(.headline)
                            .padding(.bottom)
                        
                        vis.Visuluatisation(source: self.source, cfg: cfg)
                    }.padding(10)
                }
            }
        }
    }
}
