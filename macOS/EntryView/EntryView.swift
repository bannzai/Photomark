import SwiftUI

struct EntryView: View {
  let persistenceController = PersistenceController.shared

  var body: some View {
    NavigationView {
      TagList()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}

