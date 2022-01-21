import Foundation
import Photos
import class UIKit.UIImage
import SwiftUI
import os.log

private let logger = Logger(subsystem: "com.photomark.log", category: "photoLibrary")

struct PhotoLibrary {
    func fetchAssets() -> PHFetchResult<PHAsset> {
        PHAsset.fetchAssets(with: nil)
    }

    struct AssetResponse: CustomStringConvertible, Identifiable {
        var id: String { asset.localIdentifier }
        
        let asset: PHAsset
        let image: UIImage?
        let info: [AnyHashable: Any]?

        var description: String {
            "asset: \(asset), image: \(String(describing: image)), info: \(String(describing: info))"
        }
    }
    func imageStream(for asset: PHAsset, imageLength: CGFloat) -> AsyncStream<AssetResponse> {
        AsyncStream { continuation in
            let options = PHImageRequestOptions()
            options.isSynchronous = true

            // NOTE: @param resultHandler A block that is called *one or more times* either synchronously on the current thread or asynchronously on the main thread depending on the options specified in the PHImageRequestOptions options parameter.
            PHImageManager.default().requestImage(for: asset, targetSize: .init(width: imageLength, height: imageLength), contentMode: .default, options: options) { image, info in
                let response = AssetResponse(asset: asset, image: image, info: info)
                continuation.yield(response)
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
