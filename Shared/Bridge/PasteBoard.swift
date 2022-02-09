
#if os(iOS)
import UIKit
typealias Pasteboard = UIPasteboard
#endif

#if os(macOS)
import AppKit
typealias Pasteboard = NSPasteboard

extension Pasteboard {
  var image: UIImage? {
    get {
      guard canReadObject(forClasses: [UIImage.classForCoder()], options: nil) else {
        return nil
      }

      return readObjects(forClasses: [UIImage.classForCoder()], options: nil)?.first as? UIImage
    }
    set {
      if let image = newValue {
        clearContents()
        writeObjects([image])
      }
    }
  }
}
#endif
