import Foundation
import Photos

extension PHFetchResult where ObjectType == PHAsset {
    func assets() -> [PHAsset] {
        print("[DEBUG], ", count, ", ", countOfAssets(with: .image))
        var assets: [PHAsset] = []
        for i in (0..<count) {
            assets.append(object(at: i))
        }
        return assets
    }
}

