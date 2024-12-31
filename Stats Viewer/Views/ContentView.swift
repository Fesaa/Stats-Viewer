import SwiftUI

struct ContentView: View {
    @EnvironmentObject var statsbelService: StatbelServiceImpl
    
    @State private var views: [StatbelView] = []
    @State private var filteredViews: [StatbelView] = []
    
    @State private var searchQuery: String = ""
    @State private var selectedLanguage: String = "all"
    @State private var selectedDate: Date = {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Calendar.current.date(from: DateComponents(year: currentYear, month: 1, day: 1)) ?? Date()
    }()
    
    let languages = [
        "all": "All",
        "nl": "Dutch",
        "en": "English",
        "fr": "French",
        "de": "German",
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search by name", text: $searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: searchQuery, initial: true) { _, _ in
                        applyFilters()
                    }
                
                HStack {
                    Text("Filter by Language:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(languages.keys.sorted(), id: \ .self) { key in
                            Text(languages[key]!).tag(key)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                .padding()
                .onChange(of: selectedLanguage, initial: true) { _, _ in
                    applyFilters()
                }
                
                HStack {
                    Text("Published After:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                        .onChange(of: selectedDate, initial: true) { _, _ in
                            applyFilters()
                        }
                }
                .padding()
                
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
                .navigationTitle("Views")
                .task {
                    await loadDatasources()
                    applyFilters()
                }
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
