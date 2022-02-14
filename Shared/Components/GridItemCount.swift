import SwiftUI

struct GridItemCountKey: SwiftUI.EnvironmentKey {
  static var defaultValue: Int {
    #if os(iOS)
    3
    #elseif os(macOS)
    7
    #endif
  }
}

extension EnvironmentValues {
  var gridItemCount: Int {
    get {
      self[GridItemCountKey.self]
    }
    set {
      self[GridItemCountKey.self] = newValue
    }
  }
}
