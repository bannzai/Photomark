
#if os(iOS)
import UIKit
typealias UIImage = UIKit.UIImage
#endif

#if os(macOS)
import AppKit
typealias UIImage = AppKit.NSImage


extension NSImage {
  var cgImage: CGImage? {
    var imageRect = NSRect(origin: .zero, size: size)
    guard let image = cgImage(forProposedRect: &imageRect, context: nil, hints: nil) else {
      return nil
    }
    return image
  }

  convenience init(cgImage: CGImage) {
    self.init(cgImage: cgImage, size: .init(width: cgImage.width, height: cgImage.height))
  }
}

#endif

