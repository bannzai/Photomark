import Foundation
import Photos

extension PHFetchResult where ObjectType == PHAsset {
  func assets() -> [PHAsset] {
    var assets: [PHAsset] = []
    for i in (0..<count) {
      assets.append(object(at: i))
    }
    return assets.sorted { lhs, rhs in
      if let l = lhs.creationDate?.timeIntervalSinceReferenceDate,
         let r = rhs.creationDate?.timeIntervalSinceReferenceDate {
        return l > r
      } else {
        assertionFailure()
        return false
      }
    }
  }
}

