import Foundation
import CoreData

extension Photo {
  static func create(context: NSManagedObjectContext, imageData: Data) -> Photo {
    let photo = Photo(context: context)
    photo.id = .init()
    photo.createdDate = .init()
    photo.imageData = imageData
    photo.tagIDs = []
    return photo
  }

  @discardableResult
  static func createAndSave(context: NSManagedObjectContext, imageData: Data) throws -> Photo {
    let photo = create(context: context, imageData: imageData)
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
