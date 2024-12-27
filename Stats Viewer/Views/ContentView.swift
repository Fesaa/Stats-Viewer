import SwiftUI

struct ContentView: View {
    @EnvironmentObject var statsbelService: StatbelServiceImpl
    
    @State private var views: [StatbelView] = []

    var body: some View {
        NavigationView {
            List {
                ForEach(views) { datasource in
                    NavigationLink(destination: Text("hi")) {
                        VStack(alignment: .leading) {
                            Text(datasource.name)
                                .font(.headline)
                        }
                    }
                }
            }
            .navigationTitle("Datasources")
            .task {
                await loadDatasources()
            }
        }
    }
    
    private func loadDatasources() async {
        print("Loading datasources...")
        
        do {
            let data = try await statsbelService.getAllView()
            await MainActor.run {
                views = data
            }
        } catch {
            print("Failed to load datasources: \(error)")
        }
        
        
    }
}
#Preview {
    ContentView()
        .environmentObject(StatbelServiceImpl())
}
