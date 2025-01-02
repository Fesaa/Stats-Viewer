import SwiftUI

struct StatbelViewView: View {
    
    @EnvironmentObject var statsbelService: StatbelService
    
    let statbelView: StatbelView
    
    @State var source: ExportResult? = nil
    
    var registry: Dictionary<String, (ExportResult) -> Visualisation> {
        var r = Dictionary<String, (ExportResult) -> Visualisation>();
        
        r["Simple Bar Plot"] = SimpleBarPlot.init;
        
        return r;
    }
    
    
    init(statbelView: StatbelView) {
        self.statbelView = statbelView
    }
    
    var body: some View {
        NavigationView {
            Group {
                if source == nil {
                    LoadingView()
                } else {
                    
                }
            }
        }.task {
            do {
                self.source = try await self.statsbelService.getExportResult(viewID: self.statbelView.id)
            } catch {
                print("\(error)")
            }
        }
    }
    
}
