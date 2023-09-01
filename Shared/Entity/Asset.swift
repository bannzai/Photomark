import Foundation
import Photos

@dynamicMemberLookup struct Asset: CustomStringConvertible, Identifiable, Hashable {
  var id: String { asset.localIdentifier }

  let asset: PHAsset
  let cloudIdentifier: String

  init(phAsset: PHAsset, cloudIdentifier: String) {
    self.asset = phAsset
    self.cloudIdentifier = cloudIdentifier
  }

  var description: String {
    "asset: \(asset)"
  }


  subscript<U>(dynamicMember keyPath: KeyPath<PHAsset, U>) -> U {
    asset[keyPath: keyPath]
  }
}
