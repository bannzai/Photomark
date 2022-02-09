import SwiftUI
import AppKit

struct ActivityView: NSViewRepresentable {
  let images: [UIImage]
  var onCancel: (() -> Void)?
  var onComplete: ((UIActivity.ActivityType?) -> Void)?

  func makeNSView(context: Context) -> some NSView {
    let view = NSProgressIndicator(frame: .init(origin: .zero, size: .init(width: 40, height: 40)))
    view.style = .spinning
    return view
  }
}

