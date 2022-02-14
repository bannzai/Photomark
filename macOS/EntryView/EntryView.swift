import SwiftUI

struct EntryView: View {
  let persistenceController = PersistenceController.shared

  var body: some View {
    PhotoAssetDateListPage()
      .environment(\.managedObjectContext, persistenceController.container.viewContext)
  }
}

