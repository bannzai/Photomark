import Foundation
import Photos
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
  func imageStream(for asset: Asset, deliveryMode: PHImageRequestOptionsDeliveryMode = .opportunistic) -> AsyncStream<UIImage?> {
    // NOTE: @param resultHandler A block that is called *one or more times* either synchronously on the current thread or asynchronously on the main thread depending on the options specified in the PHImageRequestOptions options parameter.
    AsyncStream { continuation in
      fetchImage(for: asset, deliveryMode: deliveryMode) { image in
        continuation.yield(image)
      }
    }
  }

  func fetchImage(for asset: Asset, deliveryMode: PHImageRequestOptionsDeliveryMode = .opportunistic, callback: @escaping (UIImage?) -> Void) {
    let targetSize: CGSize
    targetSize = PHImageManagerMaximumSize

    let options = PHImageRequestOptions()
    options.deliveryMode = deliveryMode

    // NOTE: @param resultHandler A block that is called *one or more times* either synchronously on the current thread or asynchronously on the main thread depending on the options specified in the PHImageRequestOptions options parameter.
    PHImageManager.default().requestImage(for: asset.phAsset, targetSize: targetSize, contentMode: .default, options: options) { image, info in
      callback(image)
    }
  }

  func highQualityImage(for asset: Asset) async -> UIImage? {
    await imageStream(for: asset, deliveryMode: .highQualityFormat).first { image in
      return true
    } ?? nil
  }

  private func cropToBounds(image: UIImage?, width: Double, height: Double) -> UIImage? {
    guard let image = image, let cgImage = image.cgImage else {
      return nil
    }

    let contextImage = UIImage(cgImage: cgImage)
    let contextSize = contextImage.size

    let position: CGPoint
    let size: CGSize
    if contextSize.width > contextSize.height {
      position = .init(x: (contextSize.width - contextSize.height) / 2, y: 0)
      size = .init(width: contextSize.height, height: contextSize.height)
    } else {
      position = .init(x: 0, y: (contextSize.height - contextSize.width) / 2)
      size = .init(width: contextSize.width, height: contextSize.width)
    }

    let imageRef: CGImage = cgImage.cropping(to: .init(origin: position, size: size))!
    #if os(iOS)
    return .init(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
    #elseif os(macOS)
    return .init(cgImage: imageRef)
    #endif
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
