import Foundation
import Photos

@dynamicMemberLookup struct Asset: Identifiable, Hashable {
  var id: String { phAsset.localIdentifier }

  let phAsset: PHAsset
  let cloudIdentifier: String

  init(phAsset: PHAsset, cloudIdentifier: String) {
    self.phAsset = phAsset
    self.cloudIdentifier = cloudIdentifier
  }

  subscript<U>(dynamicMember keyPath: KeyPath<PHAsset, U>) -> U {
    phAsset[keyPath: keyPath]
  }
}
