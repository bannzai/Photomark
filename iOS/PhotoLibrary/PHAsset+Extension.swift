import Foundation
import Photos

extension PHFetchResult where ObjectType == PHAsset {
  func toArray() -> [ObjectType] {
    var array: [ObjectType] = []
    for i in (0..<count) {
      array.append(object(at: i))
    }
    return array
  }
}

extension PHFetchResult where ObjectType == PHAssetCollection {
  func toArray() -> [ObjectType] {
    var array: [ObjectType] = []
    for i in (0..<count) {
      array.append(object(at: i))
    }
    return array
  }
}

