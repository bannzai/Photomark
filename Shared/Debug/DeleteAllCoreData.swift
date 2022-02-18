import Foundation
import CoreData

#if DEBUG
func deleteAllCoreData(viewContext: NSManagedObjectContext) {
  let photos: [Photo] = try! viewContext.fetch(.init(entityName: "Photo"))
  for photo in photos {
    viewContext.delete(photo)
  }

  let tags: [Tag] = try! viewContext.fetch(.init(entityName: "Tag"))
  for tag in tags {
    viewContext.delete(tag)
  }
}
#endif
