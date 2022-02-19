import SwiftUI

struct TagList: View {
  @Environment(\.managedObjectContext) var viewContext
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Tag.createdDate, ascending: false)],
    animation: .default)
  var tags: FetchedResults<Tag>

  @State var selectedElement: Tag?

  var body: some View {
    List(selection: $selectedElement) {
      ForEach(tags) { tag in
        NavigationLink(tag.name!) {
          PhotoAssetListPage(selectedTags: [tag])
            .environment(\.managedObjectContext, viewContext)
        }
        .tag(tag.id!)
      }
    }
  }
}

