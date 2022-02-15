import SwiftUI

struct TagList: View {
  @Environment(\.managedObjectContext) var viewContext
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Tag.createdDate, ascending: false)],
    animation: .default)
  var tags: FetchedResults<Tag>

  var body: some View {
    List {
      Text("すべての写真")

      ForEach(tags) { tag in
        NavigationLink(tag.Name!, destination: <#T##() -> _#>)
      }
    }
  }
}

