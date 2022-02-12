
#if os(iOS)
import UIKit
typealias Pasteboard = UIPasteboard

func saveImageToPhotoLibrary(image: UIImage) throws {
  UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
}
#endif

#if os(macOS)
import AppKit
import Foundation
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


extension NSBitmapImageRep {
  var png: Data? {
    return representation(using: .png, properties: [:])
  }
}
private extension Data {
  var bitmap: NSBitmapImageRep? {
    return NSBitmapImageRep(data: self)
  }
}
func saveImageToPhotoLibrary(image: UIImage) throws{
  guard let picturesDirectory = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first, let pngData = image.tiffRepresentation?.bitmap?.png else {
    return
  }
  let imageUrl = picturesDirectory.appendingPathComponent("image.png", isDirectory: false)
  try? pngData.write(to: imageUrl)
}
#endif
