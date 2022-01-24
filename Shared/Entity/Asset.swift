import Foundation
import Photos
import UIKit

final class Asset: CustomStringConvertible, Identifiable {
  var id: String { asset.localIdentifier }

  let asset: PHAsset
  var image: UIImage?
  var info: [AnyHashable: Any]?

  init(phAsset: PHAsset) {
    self.asset = phAsset
  }

  var description: String {
    "asset: \(asset), image: \(String(describing: image)), info: \(String(describing: info))"
  }
}
