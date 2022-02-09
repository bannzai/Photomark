import SwiftUI
import UIKit

struct IndicatorView: UIViewControllerRepresentable {

  let images: [UIImage]
  var onCancel: (() -> Void)?
  var onComplete: ((UIActivity.ActivityType?) -> Void)?

  public func makeUIViewController(context: Context) -> UIActivityViewController {
    let activityController = UIActivityViewController(activityItems: images, applicationActivities: nil)
    activityController.completionWithItemsHandler = {
      (activityType, completed, returnedItems, error) in
      if !completed {
        onCancel?()
      } else {
        onComplete?(activityType)
      }
    }
    return activityController
  }

  public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    // Noop
  }
}

