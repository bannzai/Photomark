import SwiftUI
import AppKit

struct IndicatorView: NSViewRepresentable {
  let images: [UIImage]
  var onCancel: (() -> Void)?
  var onComplete: ((UIActivity.ActivityType?) -> Void)?

  func makeNSView(context: Context) -> some NSView {
    let view = NSProgressIndicator.init(frame: .init(origin: .zero, size: .init(width: 40, height: 40)))
    view.style = .spinning
    return view
  }
}

