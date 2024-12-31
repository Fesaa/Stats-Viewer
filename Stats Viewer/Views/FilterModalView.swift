import SwiftUI

struct FilterModalView: View {
    @Binding var selectedLanguage: String
    @Binding var selectedDate: Date
    @Binding var toggle: Bool
    
    let applyFiltersCallback: () -> Void
    
    let languages = [
        "all": "All",
        "nl": "Dutch",
        "en": "English",
        "fr": "French",
        "de": "German",
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Language")) {
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(languages.keys.sorted(), id: \.self) { key in
                            Text(languages[key]!).tag(key)
                        }
                    }
                }
                
                Section(header: Text("Date")) {
                    DatePicker("Published After", selection: $selectedDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Filters")
            .navigationBarItems(trailing: Button("Done") {
                self.toggle.toggle()
                self.applyFiltersCallback()
            })
        }
    }
}
