import Foundation

extension PhotoAssetListPage {
  var filteredAssets: [Asset] {
    if selectedTags.isEmpty && searchText.isEmpty {
      return assets
    } else {
      let filteredPhotos: [(photo: Photo, photoTagIDs: [String])] = photos.toArray().compactMap { photo in
        if let tagIDs = photo.tagIDs {
          return (photo: photo, photoTagIDs: tagIDs)
        } else {
          return nil
        }
      }.filter { tuple in
        if !searchText.isEmpty {
          let filteredTags = tags.toArray().filtered(tagName: searchText)

          return tuple.photoTagIDs.contains { photoTagID in
            filteredTags.contains { $0.id?.uuidString == photoTagID }
          }
        } else {
          return true
        }
      }.filter { tuple in
        if !selectedTags.isEmpty {
          return tuple.photoTagIDs.contains { photoTagID in
            selectedTags.allSatisfy { $0.id?.uuidString == photoTagID }
          }
        } else {
          return true
        }
      }

      return assets.filter { asset in
        filteredPhotos.contains { tuple in tuple.photo.phAssetIdentifier == asset.id }
      }
    }
  }
  
  func fetchFirst() {
    let phAssets = photoLibrary.fetchAssets().toArray()
    let sortedAssets = phAssets.sorted { lhs, rhs in
      if let l = lhs.creationDate?.timeIntervalSinceReferenceDate, let r = rhs.creationDate?.timeIntervalSinceReferenceDate {
        return l > r
      } else {
        assertionFailure()
        return false
      }
    }
    assets = sortedAssets.map(Asset.init)

    let phAssetCollections = photoLibrary.fetchAssetCollection().toArray()
    let assetsInCollection = phAssetCollections.map(photoLibrary.fetchFirstAsset(in:))
    zip(phAssetCollections, assetsInCollection).forEach { (collection, asset) in
      if let asset = asset {
        albums.append(Album(collection: collection, firstAsset: Asset(phAsset: asset)))
      } else {
        albums.append(Album(collection: collection, firstAsset: nil))
      }
    }
  }
}
