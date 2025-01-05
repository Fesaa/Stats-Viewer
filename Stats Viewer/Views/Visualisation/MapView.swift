import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    var id: UUID = UUID()
    var source: ExportResult
    @State var config: Configuration
    
    @State private var annotations: [IdentifiableAnnotation] = []
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 50.8503, longitude: 4.3517), // Centered on Brussels
        latitudinalMeters: 90000, // Covers most of Belgium
        longitudinalMeters: 90000
    )
    
    var body: some View {
        Map(bounds: MapCameraBounds(centerCoordinateBounds: region, minimumDistance: 100000)) {
            ForEach(annotations) { annotation in
                Marker(annotation.title, coordinate: annotation.coordinate)
            }
        }
        .onAppear {
            setupAnnotations()
        }
    }
    
    private func setupAnnotations() {
        guard let locKey = config.getValue("loc"), let valKey = config.getValue("val") else {
            print("Configuration keys missing")
            return
        }
        
        let geocoder = CLGeocoder()
        
        for fact in source.facts {
            if let locationName = fact[locKey]?.stringValue,
               let value = fact[valKey]?.stringValue {
                
                geocoder.geocodeAddressString(locationName) { placemarks, error in
                    if let error = error {
                        print("Geocoding failed for \(locationName): \(error)")
                        return
                    }
                    
                    if let placemark = placemarks?.first, let location = placemark.location {
                        let annotation = IdentifiableAnnotation(
                            id: UUID(),
                            title: value,
                            subtitle: locationName,
                            coordinate: location.coordinate
                        )
                        
                        DispatchQueue.main.async {
                            annotations.append(annotation)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Identifiable Annotation
struct IdentifiableAnnotation: Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D
}

// MARK: - Helper Extensions for FactValue
extension FactValue {
    var stringValue: String? {
        if case .string(let value) = self {
            return value
        }
        return nil
    }
    
    var floatValue: Float? {
        if case .float(let value) = self {
            return value
        }
        return nil
    }
}

// MARK: - Preview with Sample Data
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleFacts: [Fact] = [
            ["city": .string("Brussels"), "value": .string("Capital of Belgium")],
            ["city": .string("Ghent"), "value": .string("Historic city")]
        ]
        
        let sampleExportResult = ExportResult(facts: sampleFacts)
        
        var sampleConfig = Configuration()
        sampleConfig.setValue("loc", value: "city")
        sampleConfig.setValue("val", value: "value")
        
        return MapView(source: sampleExportResult, config: sampleConfig)
    }
}





struct MapViewConfiguration: View {
    var source: ExportResult
    @Binding var cfg: Configuration
    @Binding var open: Bool
    @State private var showAlert = false
    
    private func keys() -> [String] {
        if self.source.facts.isEmpty {
                return []
            }
        return self.source.facts[0].keys.map { $0 }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Title") {
                    TextField("Title", text: $cfg.title)
                }
                Section("Location key") {
                    Picker("Key", selection: valueBinding()) {
                        ForEach(keys(), id: \.self) { key in
                            Text(key).tag(key)
                        }
                    }
                }
                
                Section("Value Key") {
                    Picker("Key", selection: locBinding()) {
                        ForEach(keys(), id: \.self) { key in
                            Text(key).tag(key)
                        }
                    }
                }
                Button(action: {
                    let xKey = valueBinding().wrappedValue
                    let yKey = locBinding().wrappedValue
                    
                    if xKey == yKey {
                        showAlert = true
                    } else {
                        self.open.toggle()
                    }
                }) {
                    Text("Close")
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                }.alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Invalid Keys"),
                        message: Text("Location- and Value-Key must be different."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }
    
    func locBinding() -> Binding<String> {
        Binding(
            get: {
                return self.cfg.getValue("loc") ?? self.keys().first ?? ""
            },
            set: {
                self.cfg.setValue("loc", value: $0)
            }
        )
    }
    
    func valueBinding() -> Binding<String> {
        Binding(
            get: {
                return self.cfg.getValue("val") ?? self.keys().first ?? ""
            },
            set: {
                self.cfg.setValue("val", value: $0)
            }
        )
    }

}
