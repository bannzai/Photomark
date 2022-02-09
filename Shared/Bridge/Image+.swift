#if os(macOS)
import SwiftUI
extension Image {
  init(uiImage: UIImage) {
    self.init(nsImage: uiImage)
  }
}
#endif
