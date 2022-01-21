import Foundation
import CoreData

protocol CoreDataFactory: AnyObject {
    static func create(context: NSManagedObjectContext) -> Self
}

extension NSManagedObject: CoreDataFactory {
    @objc class func create(context: NSManagedObjectContext) -> Self {
        fatalError("Subclass implementation")
    }
}

extension Photo {
    override class func create(context: NSManagedObjectContext) -> Self {
        let photo = Photo(context: context)
        photo.id = .init()
        photo.createdDate = .init()
        return photo as! Self
    }
}

extension Tag {
    override class func create(context: NSManagedObjectContext) -> Self {
        let tag = Tag(context: context)
        tag.id = .init()
        tag.createdDate = .init()
        return tag as! Self
    }
}
