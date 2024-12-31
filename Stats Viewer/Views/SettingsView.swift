import SwiftUI

struct SettingsView: View {
    @Binding var toggle: Bool
    

    var body: some View {
        NavigationView {
            Form {
                
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                self.toggle.toggle()
            })
        }
    }
}
