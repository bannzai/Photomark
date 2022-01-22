import Foundation
import UIKit
import SwiftUI
import PhotosUI
import Photos
import Combine

struct PhotoLibraryPicker: UIViewControllerRepresentable {
  @Environment(\.dismiss) private var dismiss

  @Binding var error: Error?

  let photoLibrary: PhotoLibrary
  let selected: (PHPickerResult) -> Void

  func makeUIViewController(context: Context) -> PHPickerViewController {
    let configuration: PHPickerConfiguration = {
      var configuration: PHPickerConfiguration = .init(photoLibrary: PHPhotoLibrary.shared())
      configuration.filter = .images
      configuration.selectionLimit = 1
      return configuration
    }()

    let controller = PHPickerViewController(configuration: configuration)
    controller.delegate = context.coordinator
    return controller
  }

  func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {

  }

  func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }

  class Coordinator: PHPickerViewControllerDelegate {
    let parent: PhotoLibraryPicker
    init(parent: PhotoLibraryPicker) {
      self.parent = parent
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
      guard let result = results.first else {
        parent.dismiss()
        return
      }

      parent.selected(result)
      parent.dismiss()
    }
  }
}
