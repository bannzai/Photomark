import Foundation
import Photos

struct Asset: CustomStringConvertible, Identifiable, Hashable {
  var id: String { asset.localIdentifier }

  let asset: PHAsset

  init(phAsset: PHAsset) {
    self.asset = phAsset
  }

  var description: String {
    "asset: \(asset)"
  }
}
