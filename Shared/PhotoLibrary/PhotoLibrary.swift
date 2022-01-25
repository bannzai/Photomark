import Foundation
import Photos
import class UIKit.UIImage
import SwiftUI
import os.log

private let logger = Logger(subsystem: "com.photomark.log", category: "photoLibrary")

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
  func fetchFirstAsset(in assetCollection: PHAssetCollection) -> PHAsset? {
    let options = PHFetchOptions()
    options.fetchLimit = 1
    return PHAsset.fetchAssets(in: assetCollection, options: options).firstObject
  }

  func fetchAssetCollection() -> PHFetchResult<PHAssetCollection> {
    PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
  }

  // NOTE: Nullable, because there is a possibility that phAssetIdentifier remains only in Photo DB.
  // Sinario: User deleted asset on Photo.app.
  func fetch(phIdentifier: String) -> PHAsset? {
    PHAsset.fetchAssets(withLocalIdentifiers: [phIdentifier], options: nil).firstObject
  }

  // Doc: https://developer.apple.com/documentation/photokit/phimagemanager/1616964-requestimage
  // For an asynchronous request, Photos may call your result handler block more than once. Photos first calls the block to provide a low-quality image suitable for displaying temporarily while it prepares a high-quality image. (If low-quality image data is immediately available, the first call may occur before the method returns.) When the high-quality image is ready, Photos calls your result handler again to provide it. If the image manager has already cached the requested image at full quality, Photos calls your result handler only once. The PHImageResultIsDegradedKey key in the result handler’s info parameter indicates when Photos is providing a temporary low-quality image.
  func imageStream(for asset: Asset, maxImageLength: CGFloat) -> AsyncStream<UIImage?> {
    AsyncStream { continuation in
      // NOTE: @param resultHandler A block that is called *one or more times* either synchronously on the current thread or asynchronously on the main thread depending on the options specified in the PHImageRequestOptions options parameter.
      PHImageManager.default().requestImage(for: asset.asset, targetSize: .init(width: maxImageLength, height: maxImageLength), contentMode: .default, options: nil) { image, info in
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
