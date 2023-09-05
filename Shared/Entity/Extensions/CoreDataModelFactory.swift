import Foundation
import CoreData
import Photos

// PhotoはAssetをもとに作られる。Assetは存在しているがPhotoは存在していない場合がある。PhotoはAssetに対して何かしらアクションを行われた時に作成される
// これはPHAssetをしたらPhotoを作成する。あるいは以前まで存在していたPHAssetが消されてPhotoが存在しない場合も考慮に入れ、AssetとPhotoの存在性を強く結び付けないためである。なので、Photoはコンポーネントの引数に渡されるときは基本的にOptionalになる
extension Photo {
  private static func create(context: NSManagedObjectContext, asset: Asset) throws -> Photo {
    let photo = Photo(context: context)
    photo.id = .init()
    photo.phAssetCloudIdentifier = asset.cloudIdentifier
    photo.phAssetLocalIdentifier = asset.localIdentifier
    photo.createdDateTime = .init()
    photo.lastCopiedDateTime = nil
    photo.lastTagAddedDateTime = nil
    photo.lastAssetDownloadedDateTime = nil
    photo.tagIDs = []
    return photo
  }

  @discardableResult
  static func createAndSave(context: NSManagedObjectContext, asset: Asset) throws -> Photo {
    let photo = try create(context: context, asset: asset)
    try context.save()
    return photo
  }
}

extension Tag {
  private static func create(context: NSManagedObjectContext, name _name: String) -> Tag? {
    let name = _name.trimmed
    if name.isEmpty {
      return nil
    }

    let tag = Tag(context: context)
    tag.id = .init()
    tag.name = name
    tag.createdDateTime = .init()
    return tag
  }

  @discardableResult
  static func createAndSave(context: NSManagedObjectContext, name: String) throws -> Tag? {
    guard let tag = Tag.create(context: context, name: name) else {
      return nil
    }

    try context.save()
    return tag
  }
}
