import Foundation
import Photos

struct Asset: CustomStringConvertible, Identifiable, Hashable {
  var id: String { asset.localIdentifier }
  var cloudIdentifier: String? {
    get {
      print("[DEBUG] begin: ", Date().timeIntervalSince1970)
      let id = try? Photos.PHPhotoLibrary.shared().cloudIdentifierMappings(forLocalIdentifiers: [asset.localIdentifier])[asset.localIdentifier]?.get().stringValue
      print("[DEBUG] end: ", Date().timeIntervalSince1970)
      return id
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
