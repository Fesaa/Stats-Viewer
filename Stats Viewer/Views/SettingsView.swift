import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var statbelService: StatbelService
    let cache: any CacheService = CacheServiceImpl.shared

    @Binding var toggle: Bool
    let reload: () async -> Void

    @State private var showNotification: Bool = false
    @State private var notificationMessage: String = ""

    var body: some View {
        NavigationView {
            Form {
                Button(action: {
                    Task {
                        await self.clearViewsCache()
                    }
                }) {
                    Text("Reset Cache")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(
                trailing: Button("Done") {
                    self.toggle.toggle()
                }
            )
            .alert(isPresented: $showNotification) {
                // TODO: Make this a bit more sofisticated
                Alert(
                    title: Text("Notification"),
                    message: Text(notificationMessage),
                    dismissButton: .default(Text("OK")))
            }
        }
    }

    func clearViewsCache() async {
        do {
            try self.cache.delete(key: "views")
            self.notificationMessage = "Views cache cleared!"
            self.showNotification = true
        } catch {
            self.notificationMessage = "Views cache clearing failed!"
            self.showNotification = true
        }
        await self.reload()
    }
}
