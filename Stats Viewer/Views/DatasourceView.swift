import SwiftUI


struct DatasourceView: View {
    
    var source: Datasource
    
    init(source: Datasource) {
        self.source = source
    }

    var body: some View {
        Text("Info for \(self.source.name)")
    }
    
    
}
