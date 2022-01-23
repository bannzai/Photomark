import Foundation
import Photos

extension PHFetchResult where ObjectType == PHAsset {
  func toArray() -> [PHAsset] {
    var assets: [PHAsset] = []
    for i in (0..<count) {
      assets.append(object(at: i))
    }
    return assets
  }
}

