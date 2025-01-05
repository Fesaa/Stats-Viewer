import SwiftUI

struct TableView: View {
    var id: UUID = UUID()
    var source: ExportResult
    @State var config: Configuration

    var body: some View {
        NavigationView {
            List {
                ScrollView(.horizontal) {
                    VStack(alignment: .leading) {
                        TableHeaderView(keys: visibleKeys())

                        ForEach(source.facts.indices, id: \.self) { index in
                            TableRowView(keys: visibleKeys(), fact: source.facts[index])
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Table View")
        }
    }

    private func visibleKeys() -> [String] {
        let ignore = config.getValues("ignore")
        guard let firstFact = source.facts.first else { return [] }
        return firstFact.keys.filter { !ignore.contains($0) }
    }
}

struct TableHeaderView: View {
    var keys: [String]

    var body: some View {
        HStack {
            ForEach(keys, id: \.self) { key in
                Text(key.capitalized)
                    .font(.headline)
                    .frame(width: 120, alignment: .leading)
            }
        }
        .padding(.vertical, 5)
    }
}

struct TableRowView: View {
    var keys: [String]
    var fact: Fact

    var body: some View {
        HStack {
            ForEach(keys, id: \.self) { key in
                if let value = fact[key] {
                    Text(value.description)
                        .frame(width: 120, alignment: .leading)
                } else {
                    Text("-")
                        .frame(width: 120, alignment: .leading)
                }
            }
        }
        .padding(.vertical, 2)
    }
}



extension FactValue {
    var description: String {
        switch self {
        case .string(let stringValue):
            return stringValue
        case .float(let floatValue):
            return String(floatValue)
        case .none:
            return "None"
        }
    }
}



struct TableConfigurationView: View {
    var source: ExportResult
    @Binding var cfg: Configuration
    @Binding var open: Bool
    
    private func keys() -> [String] {
        if self.source.facts.isEmpty {
            return []
        }
        return self.source.facts[0].keys.map { $0 }.filter {
            return !$0.isEmpty
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Title") {
                    TextField("Title", text: $cfg.title)
                }
                
                /*Section(header: Text("Ignore List")) {
                    List {
                        ForEach(ignoreBindings().wrappedValue, id: \.self) { item in
                            HStack {
                                Text(item)
                                Spacer()
                                Button(action: {
                                    removeFromIgnore(item)
                                }) {
                                    Image(systemName: "minus.circle")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .onDelete(perform: deleteFromIgnore)
                    }
                    HStack {
                        TextField("Add item", text: Binding(
                            get: { "" },
                            set: { addToIgnore($0) }
                        ))
                        Button(action: {
                            addToIgnore("")
                        }) {
                            Image(systemName: "plus.circle")
                        }
                    }
                }*/
                
                Section(header: Text("Key Dropdown")) {
                    Picker("Select a key", selection: keyBinding()) {
                        ForEach(keys(), id: \.self) { key in
                            Text(key).tag(key)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                Button(action: { self.open.toggle() }) {
                    Text("Close")
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Table Configuration")
        }
    }
    
    func ignoreBindings() -> Binding<[String]> {
        Binding(
            get: {
                return self.cfg.getValues("ignore")
            },
            set: {
                self.cfg.setValues("ignore", values: $0)
            }
        )
    }
    
    func keyBinding() -> Binding<String> {
        Binding(
            get: {
                return self.cfg.getValue("key") ?? ""
            },
            set: {
                self.cfg.setValue("key", value: $0)
            }
        )
    }
    
    func addToIgnore(_ value: String) {
        guard !value.isEmpty else { return }
        var current = ignoreBindings().wrappedValue
        if !current.contains(value) {
            current.append(value)
            ignoreBindings().wrappedValue = current
        }
    }
    
    func removeFromIgnore(_ value: String) {
        var current = ignoreBindings().wrappedValue
        current.removeAll { $0 == value }
        ignoreBindings().wrappedValue = current
    }
    
    func deleteFromIgnore(at offsets: IndexSet) {
        var current = ignoreBindings().wrappedValue
        current.remove(atOffsets: offsets)
        ignoreBindings().wrappedValue = current
    }
}
