
#if os(ios)
import UIKit
typealias UIImage = UIKit.UIImage
#endif

#if os(macOS)
import AppKit
typealias UIImage = AppKit.NSImage
#endif

