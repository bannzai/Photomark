import Foundation
import CoreData

extension Photo {
  static func create(context: NSManagedObjectContext, imageData: Data) -> Photo {
    let photo = Photo(context: context)
    photo.id = .init()
    photo.createdDate = .init()
    photo.imageData = imageData
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
  static func create(context: NSManagedObjectContext, name: String) -> Tag {
    let tag = Tag(context: context)
    tag.id = .init()
    tag.name = name
    tag.createdDate = .init()
    return tag
  }

  @discardableResult
  static func createAndSave(context: NSManagedObjectContext, name: String) throws -> Tag {
    let tag = Tag.create(context: context, name: name)
    try context.save()
    return tag
  }
}
