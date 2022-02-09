
#if os(iOS)
import UIKit
typealias UIImage = UIKit.UIImage
#endif

#if os(macOS)
import AppKit
typealias UIImage = AppKit.NSImage


extension NSImage {
  var toCGImage: CGImage {
    var imageRect = NSRect(origin: .zero, size: size)
    guard let image = cgImage(forProposedRect: &imageRect, context: nil, hints: nil) else {
      abort()
    }
    return image
  }
}
#endif

