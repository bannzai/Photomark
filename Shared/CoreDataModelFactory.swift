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
}

extension Tag {
    static func create(context: NSManagedObjectContext) -> Tag {
        let tag = Tag(context: context)
        tag.id = .init()
        tag.createdDate = .init()
        return tag
    }
}
