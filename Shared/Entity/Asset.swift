import Foundation
import Photos

final class Asset: CustomStringConvertible, Identifiable, Hashable {
  var id: String { asset.localIdentifier }
  var cloudIdentifier: String?

  let asset: PHAsset
  init(phAsset: PHAsset) {
    self.asset = phAsset
    asyncSetCloudIdentifier()
  }

  func asyncSetCloudIdentifier() {
    DispatchQueue.global().async {
      let cloudIdentifier = try? Photos.PHPhotoLibrary.shared().cloudIdentifierMappings(forLocalIdentifiers: [self.asset.localIdentifier])[self.asset.localIdentifier]?.get().stringValue

      DispatchQueue.main.async {
        self.cloudIdentifier = cloudIdentifier
      }
    }
  }

  var description: String {
    "asset: \(asset)"
  }

  static func == (lhs: Asset, rhs: Asset) -> Bool {
    lhs.asset == rhs.asset
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(asset)
  }
}
