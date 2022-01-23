import Foundation
import SwiftUI
import CoreData

@MainActor final class AppViewModel: ObservableObject {
  @Environment(\.managedObjectContext) private var viewContext

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Tag.createdDate, ascending: false)],
    animation: .default)
  private var tags: FetchedResults<Tag>
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Photo.createdDate, ascending: false)],
    animation: .default)
  private var photos: FetchedResults<Photo>

  func photo(id: Photo.ID) -> Photo? {
    photos.first(where: { $0.id == id })
  }
  func tag(id: Tag.ID) -> Tag? {
    tags.first(where: { $0.id == id })
  }
}
