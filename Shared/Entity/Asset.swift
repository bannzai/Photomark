import Foundation
import Photos

struct Asset: CustomStringConvertible, Identifiable, Hashable {
  var id: String { asset.localIdentifier }
  var cloudIdentifier: String? {
    get {
      try? Photos.PHPhotoLibrary.shared().cloudIdentifierMappings(forLocalIdentifiers: [asset.localIdentifier])[asset.localIdentifier]?.get().stringValue
    }
  }

  let asset: PHAsset

  init(phAsset: PHAsset) {
    self.asset = phAsset
  }

  var description: String {
    "asset: \(asset)"
  }
}
