import SwiftUI

struct EntryView: View {
  let persistenceController = PersistenceController.shared

  var body: some View {
    RootView()
      .environment(\.managedObjectContext, persistenceController.container.viewContext)
  }
}

struct RootView: View {
  @Environment(\.managedObjectContext) private var viewContext

  @State var detailPageArgument: Asset?

  var body: some View {
      HSplitView {
        // Left sidebar
        TagList()

        // Right Sidebar
        if let detailPageAsset = detailPageAsset {

        }
    }
  }
}
