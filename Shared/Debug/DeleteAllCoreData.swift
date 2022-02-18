import Foundation
import CoreData

#if DEBUG
func deleteAllCoreData() {
  let viewContext = PersistenceController.shared.container.viewContext

  let photosDeleteRequest = NSBatchDeleteRequest(fetchRequest: .init(entityName: "Photo"))
  try! PersistenceController
    .shared
    .container
    .persistentStoreCoordinator.execute(photosDeleteRequest, with: viewContext)

  let tagsDeleteRequest = NSBatchDeleteRequest(fetchRequest: .init(entityName: "Tag"))
  try! PersistenceController
    .shared
    .container
    .persistentStoreCoordinator.execute(tagsDeleteRequest, with: viewContext)
}
#endif
