import SwiftUI
import UIKit

struct IndicatorView: UIViewControllerRepresentable {

  let images: [UIImage]
  var onCancel: (() -> Void)?
  var onComplete: ((UIActivity.ActivityType?) -> Void)?

  public func makeUIViewController(context: Context) -> UIIndicatorViewController {
    let activityController = UIIndicatorViewController(activityItems: images, applicationActivities: nil)
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

  public func updateUIViewController(_ uiViewController: UIIndicatorViewController, context: Context) {
    // Noop
  }
}

