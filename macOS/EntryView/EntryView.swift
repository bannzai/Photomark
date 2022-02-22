import SwiftUI

struct EntryView: View {
  let persistenceController = PersistenceController.shared

  var body: some View {
    NavigationView {
      HSplitView {
        TagList()
          .environment(\.managedObjectContext, persistenceController.container.viewContext)
      }
    }
  }
}

