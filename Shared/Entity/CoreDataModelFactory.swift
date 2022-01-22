import Foundation
import CoreData

extension Photo {
  static func create(context: NSManagedObjectContext, asset: Asset) -> Photo {
    let photo = Photo(context: context)
    photo.id = .init()
    photo.phAssetIdentifier = asset.id
    photo.createdDate = .init()
    photo.tagIDs = []
    return photo
  }

  @discardableResult
  static func createAndSave(context: NSManagedObjectContext, asset: Asset) throws -> Photo {
    let photo = create(context: context, asset: asset)
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
    tag.name = name.trimmed
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
