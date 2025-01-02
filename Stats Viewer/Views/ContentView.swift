import SwiftUI

struct ContentView: View {
    @EnvironmentObject var statsbelService: StatbelService
    
    @State private var views: [StatbelView] = []
    @State private var filteredViews: [StatbelView] = []
    
    @State private var searchQuery: String = ""
    @State private var selectedLanguage: String = "all"
    @State private var selectedDate: Date = {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Calendar.current.date(from: DateComponents(year: currentYear-1, month: 1, day: 1)) ?? Date()
    }()
    @State private var showSettingsSheet: Bool = false
    @State private var showFilterSheet: Bool = false
    
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search by name", text: $searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: searchQuery, initial: true) { _, _ in
                        applyFilters()
                    }
                
                if (filteredViews.count == 0) {
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                        
                        Text("No views found")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredViews) { view in
                            NavigationLink(destination: StatbelViewView(statbelView: view)) {
                                VStack(alignment: .leading) {
                                    Text(view.name)
                                        .font(.headline)
                                        .padding(.bottom, 2)
                                    Text("Last updated on: \(formattedDate(view.getLastChangeDate()))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    }
                }
            }.toolbar {
                Button(action: {
                    showFilterSheet.toggle()
                }) {
                    Image(systemName: "magnifyingglass")
                }
                Button(action: {
                    showSettingsSheet.toggle()
                }) {
                    Image(systemName: "gear")
                }
            }
            .sheet(isPresented: $showSettingsSheet) {
                SettingsView(toggle: $showSettingsSheet, reload: loadViews)
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterModalView(selectedLanguage: $selectedLanguage, selectedDate: $selectedDate, toggle: $showFilterSheet, applyFiltersCallback: applyFilters)
            }.navigationTitle(filteredViews.count > 0 ? "Views (\(filteredViews.count))" : "Views")
                .task {
                    await loadViews()
                    applyFilters()
                }
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func applyFilters() {
        filteredViews = views.filter { view in
            let matchesSearch = searchQuery.isEmpty || view.name.lowercased().contains(searchQuery.lowercased())
            let matchesLanguage = selectedLanguage == "all" || view.locale == selectedLanguage
            let matchesDate = view.getLastChangeDate() >= selectedDate
            return matchesSearch && matchesLanguage && matchesDate
        }
    }
    
    private func loadViews() async {
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
        .environmentObject(StatbelService())
        .environmentObject(CacheServiceImpl())
}
