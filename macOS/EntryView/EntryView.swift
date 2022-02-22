import SwiftUI

struct EntryView: View {
  let persistenceController = PersistenceController.shared

  @State var showsDetailPage = false

  var body: some View {
      HSplitView {
        // Left sidebar
        TagList()
          .environment(\.managedObjectContext, persistenceController.container.viewContext)

        // Right Sidebar
        if showsDetailPage {
          
        }
    }
  }
}
