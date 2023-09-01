import Foundation
import Photos

@dynamicMemberLookup struct Asset: Hashable {
  let phAsset: PHAsset
  let cloudIdentifier: String

  subscript<U>(dynamicMember keyPath: KeyPath<PHAsset, U>) -> U {
    phAsset[keyPath: keyPath]
  }
}
