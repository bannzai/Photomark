import Foundation
import SwiftUI
import CoreData

struct TagLine<Content: View>: View {
  let tags: [Tag]
  @ViewBuilder let content: (Tag) -> (Content)

  var body: some View {
    ScrollView(.horizontal) {
      HStack(alignment: .center, spacing: 10) {
        ForEach(tags) { tag in
          content(tag)
        }
      }
    }
  }
}

struct TagView: View {
  let tag: Tag
  let isSelected: Bool

  var body: some View {
    if let name = tag.name {
      Text(name)
        .frame(minWidth: 60, maxWidth: .infinity)
        .padding(8)
        .background(
          RoundedRectangle(cornerRadius: 16)
            .fill(isSelected ? Color.pink.opacity(0.4) : Color.gray.opacity(0.2))
        )
    }
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
    TagLine(tags: tags) { tag in
      TagView(tag: tag, isSelected: tag.name == "A")
    }
  }
}
