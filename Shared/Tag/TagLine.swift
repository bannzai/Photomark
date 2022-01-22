import Foundation
import SwiftUI
import CoreData

struct TagLine: View {
  var photo: Photo?
  let tags: [Tag]
  let onTap: (Tag) -> Void

  var body: some View {
    ScrollView(.horizontal) {
      HStack(alignment: .center, spacing: 10) {
        ForEach(tags) { tag in
          TagView(photo: photo, tag: tag)
            .onTapGesture {
              onTap(tag)
            }
        }
      }
    }
  }
}

struct TagView: View {
  var photo: Photo?
  let tag: Tag

  var body: some View {
    if let name = tag.name {
      Text(name)
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(
          RoundedRectangle(cornerRadius: 16)
            .fill(tagIsAssociatedPhoto ? Color.pink.opacity(0.4) : Color.gray.opacity(0.2))
        )
        .frame(minWidth: 60)
    }
  }

  var tagIsAssociatedPhoto: Bool {
    guard let photoTagIDs = photo?.tagIDs else {
      return false
    }
    return photoTagIDs.contains { $0 == tag.id?.uuidString }
  }
}

struct TagLine_Previews: PreviewProvider {
  static var viewContext: NSManagedObjectContext { PersistenceController.preview.container.viewContext }
  static let tags: [Tag] = ["A", "B", "C", "D", "E", "F", "G"].map {
    let tag = Tag(context: viewContext)
    tag.id = .init()
    tag.name = $0
    return tag
  }

  static var previews: some View {
    TagLine(tags: tags, onTap: { _ in })
  }
}
