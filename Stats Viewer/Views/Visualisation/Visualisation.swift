import SwiftUI

public protocol Visualisation: Identifiable {
    func optionModels() -> AnyView
    func visualisation() -> AnyView
    func isValid() -> Bool
    func errors() -> [String]
}

struct AnyVisualisation: Identifiable {
    private let _id: AnyHashable
    private let _optionModels: () -> AnyView

    var id: AnyHashable { _id }

    init<V: Visualisation>(_ visualisation: V) {
        self._id = visualisation.id
        self._optionModels = visualisation.optionModels
    }

    func optionModels() -> AnyView {
        _optionModels()
    }
}
