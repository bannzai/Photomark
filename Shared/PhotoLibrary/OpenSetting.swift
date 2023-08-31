import Foundation

#if os(iOS)
import UIKit
func openSetting() {
  let settingURL = URL(string: UIApplication.openSettingsURLString)!
  if UIApplication.shared.canOpenURL(settingURL) {
    UIApplication.shared.open(settingURL)
  }
}
#endif

#if os(macOS)
import AppKit
func openSetting() {
  NSWorkspace.shared.open(.init(string: "x-apple.systempreferences:com.apple.preference.security?Privacy")!)
}
#endif

import SwiftUI
extension SwiftUI.View {
  
}
