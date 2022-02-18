import Foundation
import CoreData
import Photos

extension Photo {
  static func create(context: NSManagedObjectContext, asset: Asset) throws -> Photo {
    let photo = Photo(context: context)
    photo.id = .init()
    let cloudIdentifier = try (Photos.PHPhotoLibrary.shared().cloudIdentifierMappings(forLocalIdentifiers: [asset.id])[asset.id]!.get())
    photo.phAssetCloudIdentifier = cloudIdentifier.stringValue
    photo.phAssetIdentifier = asset.id
    photo.createdDate = .init()
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
  static func create(context: NSManagedObjectContext, name _name: String) -> Tag? {
    let name = _name.trimmed
    if name.isEmpty {
      return nil
    }

    let tag = Tag(context: context)
    tag.id = .init()
    tag.name = name
    tag.createdDate = .init()
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
