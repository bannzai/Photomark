import SwiftUI

struct ScreenSizeEnvironmentKey: EnvironmentKey {
  static var defaultValue: CGSize = .zero
}

extension EnvironmentValues {
  var screenSize: CGSize {
    get {
      self[ScreenSizeEnvironmentKey.self]
    }
    set {
      self[ScreenSizeEnvironmentKey.self] = newValue
    }
  }
}

struct ScreenSizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
    value = nextValue()
  }
}
