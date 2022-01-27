import Foundation
import Photos
import UIKit

struct Album: Identifiable {
  var id: String { collection.localIdentifier }

  let collection: PHAssetCollection
  var firstAsset: Asset?
}
