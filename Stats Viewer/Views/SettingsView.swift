import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var statbelService: StatbelService
    let cache: CacheService = CacheService.shared

    @Binding var toggle: Bool
    let reload: () async -> Void

    @State private var cachedItems: [(key: String, date: Date)] = []
    @State private var showNotification: Bool = false
    @State private var notificationMessage: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Views Cache")) {
                    if let viewsCacheDate = getCacheDate(forKey: "views") {
                        Button(action: {
                            Task {
                                await self.clearViewsCache()
                            }
                        }) {
                            Text("Reset Views Cache (Saved: \(formattedDate(viewsCacheDate)))")
                                .foregroundColor(.red)
                        }
                    } else {
                        Text("Views cache not found")
                            .foregroundColor(.gray)
                    }
                }

                Section(header: Text("All Cached Items")) {
                    if cachedItems.isEmpty {
                        Text("No cached items found.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(cachedItems, id: \ .key) { item in
                            HStack {
                                Text("\(item.key) (Saved: \(formattedDate(item.date)))")
                                Spacer()
                                Button(action: {
                                    Task {
                                        await deleteCache(forKey: item.key)
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(
                trailing: Button("Done") {
                    self.toggle.toggle()
                }
            )
            .alert(isPresented: $showNotification) {
                Alert(
                    title: Text("Notification"),
                    message: Text(notificationMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                Task {
                    await loadCachedItems()
                }
            }
        }
    }

    func getCacheDate(forKey key: String) -> Date? {
        do {
            return try cache.age(key)
        } catch {
            print("Failed to load cache date \(error)")
            return nil
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    func loadCachedItems() async {
        do {
            self.cachedItems = try cache.listAllKeysAndDates()
                .filter { $0.key != "views" }
            print("Loaded \(self.cachedItems.count) cached items")
        } catch {
            print("Failed to load item? \(error)")
            self.cachedItems = []
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

    func deleteCache(forKey key: String) async {
        do {
            try cache.delete(key: key)
            self.notificationMessage = "Cache for \(key) cleared!"
            self.showNotification = true
            await loadCachedItems()
        } catch {
            self.notificationMessage = "Failed to clear cache for \(key)."
            self.showNotification = true
        }
    }
}
