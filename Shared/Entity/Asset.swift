import Foundation
import Photos

struct Asset: Identifiable, Hashable {
  let id: String
  var localIdentifier: String { id }
  let cloudIdentifier: String?

  init(phAsset: PHAsset, cloudIdentifier: String?) {
    self.id = phAsset.localIdentifier
    self.cloudIdentifier = cloudIdentifier
  }

  var asset: PHAsset? {
    PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject
  }
}
