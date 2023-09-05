import Foundation
import Photos

@dynamicMemberLookup struct Asset: Hashable {
  let phAsset: PHAsset
  // FIXME: cloudIdentifier使わない(使えない)かも。Photosから直接取得す流手段が無い。外部サービスとの連携を考えると便利なIdentifierだと今は考えている。なので、消しても良い
  let cloudIdentifier: String?

  subscript<U>(dynamicMember keyPath: KeyPath<PHAsset, U>) -> U {
    phAsset[keyPath: keyPath]
  }
}
