import Foundation
import Photos
import class UIKit.UIImage
import SwiftUI
import os.log

private let logger = Logger(subsystem: "com.photomark.log", category: "photoLibrary")

final class Asset: CustomStringConvertible, Identifiable {
  var id: String { asset.localIdentifier }

  let asset: PHAsset
  var image: UIImage?
  var info: [AnyHashable: Any]?

  init(phAsset: PHAsset) {
    self.asset = phAsset
  }

  var description: String {
    "asset: \(asset), image: \(String(describing: image)), info: \(String(describing: info))"
  }
}

struct PhotoLibrary {
  enum AuthorizationAction {
    case openSettingApp
    case requestAuthorization
  }

  func authorizationAction() -> AuthorizationAction? {
    let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    switch status {
    case .authorized, .limited:
      return nil
    case .restricted, .denied:
      return .openSettingApp
    case .notDetermined:
      return .requestAuthorization
    @unknown default:
      assertionFailure("unexpected authorization status \(status):\(status.rawValue)")
      return nil
    }
  }

  func requestAuthorization() async -> PHAuthorizationStatus {
    await withCheckedContinuation { continuation in
      PHPhotoLibrary.requestAuthorization { (status) in
        continuation.resume(returning: status)
      }
    }
  }

  func fetchAssets() -> PHFetchResult<PHAsset> {
    PHAsset.fetchAssets(with: nil)
  }

  // NOTE: Nullable, because there is a possibility that phAssetIdentifier remains only in Photo DB.
  // Sinario: User deleted asset on Photo.app.
  func fetch(phIdentifier: String) -> PHAsset? {
    PHAsset.fetchAssets(withLocalIdentifiers: [phIdentifier], options: nil).firstObject
  }

  func firstImage(asset: Asset, maxImageLength: CGFloat) async -> UIImage? {
    await imageStream(for: asset, maxImageLength: maxImageLength).first { _ in
      return true
    } ?? nil
  }

  func imageStream(for asset: Asset, maxImageLength: CGFloat) -> AsyncStream<UIImage?> {
    AsyncStream { continuation in
      let options = PHImageRequestOptions()
      options.isSynchronous = true

      // NOTE: @param resultHandler A block that is called *one or more times* either synchronously on the current thread or asynchronously on the main thread depending on the options specified in the PHImageRequestOptions options parameter.
      PHImageManager.default().requestImage(for: asset.asset, targetSize: .init(width: maxImageLength, height: maxImageLength), contentMode: .default, options: options) { image, info in
        continuation.yield(image)
      }
    }
  }
}

struct PhotoLibraryKey: SwiftUI.EnvironmentKey {
  static var defaultValue: PhotoLibrary = .init()
}

extension EnvironmentValues {
  var photoLibrary: PhotoLibrary {
    get {
      self[PhotoLibraryKey.self]
    }
    set {
      self[PhotoLibraryKey.self] = newValue
    }
  }
}
