import Foundation
import Photos
import class UIKit.UIImage
import SwiftUI
import os.log

private let logger = Logger(subsystem: "com.photomark.log", category: "photoLibrary")

struct PhotoLibrary {
    func photoLibraryAllPhotoMetadata() {
        let fetchResult = PHAsset.fetchAssets(with: nil)
        fetchResult.object(at: 1)
        logger.debug("[DEBUG], \(fetchResult.countOfAssets(with: .image))")
    }

    struct StreamSet: CustomStringConvertible {
        let asset: PHAsset
        let image: UIImage?
        let info: [AnyHashable: Any]?

        var description: String {
            "asset: \(asset), image: \(String(describing: image)), info: \(String(describing: info))"
        }
    }
    func imageStream(for asset: PHAsset, edge: CGFloat) async -> AsyncStream<StreamSet> {
        AsyncStream { continuation in
            // NOTE: @param resultHandler A block that is called *one or more times* either synchronously on the current thread or asynchronously on the main thread depending on the options specified in the PHImageRequestOptions options parameter.
            PHImageManager.default().requestImage(for: asset, targetSize: .init(width: edge, height: edge), contentMode: .aspectFill, options: nil) { image, info in
                let set = StreamSet(asset: asset, image: image, info: info)
                logger.debug("[DEBUG], \(set)")
                continuation.yield(set)
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
