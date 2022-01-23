import Foundation
import Photos
import class UIKit.UIImage
import SwiftUI
import os.log

private let logger = Logger(subsystem: "com.photomark.log", category: "photoLibrary")

struct Asset: CustomStringConvertible, Identifiable {
  var id: String { asset.localIdentifier }

  let asset: PHAsset
  let image: UIImage?
  let info: [AnyHashable: Any]?

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

  func firstAsset(phAsset: PHAsset, maxImageLength: CGFloat) async -> Asset? {
    await imageStream(for: phAsset, maxImageLength: maxImageLength).first { assetResponse in
      return true
    }
  }

  func imageStream(for asset: PHAsset, maxImageLength: CGFloat) -> AsyncStream<Asset> {
    AsyncStream { continuation in
      let options = PHImageRequestOptions()
      options.isSynchronous = true

      // NOTE: @param resultHandler A block that is called *one or more times* either synchronously on the current thread or asynchronously on the main thread depending on the options specified in the PHImageRequestOptions options parameter.
      PHImageManager.default().requestImage(for: asset, targetSize: .init(width: maxImageLength, height: maxImageLength), contentMode: .default, options: options) { image, info in
        continuation.yield(.init(asset: asset, image: image, info: info))
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
