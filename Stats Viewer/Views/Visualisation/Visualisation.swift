
import SwiftUI

public protocol Visualisation {
    func optionModels() -> any View;
    func visualisation() -> any View;
    func isValid() -> Bool;
    func errors() -> [String];
    func enable();
    func disable();
    func isEnabled() -> Bool;
}

class BaseVisualisation: Visualisation {
    private var enabled: Bool = false
    
    public func enable() {
        enabled = true
    }
    
    public func disable() {
        enabled = false
    }
    
    public func isEnabled() -> Bool {
        enabled
    }
    
    public func optionModels() -> any View {
        fatalError("`optionModels()` must be overridden.")
    }
    
    public func visualisation() -> any View {
        fatalError("`visualisation()` must be overridden.")
    }
    
    public func isValid() -> Bool {
        fatalError("`isValid()` must be overridden.")
    }
    
    public func errors() -> [String] {
        fatalError("`errors()` must be overridden.")
    }
}

