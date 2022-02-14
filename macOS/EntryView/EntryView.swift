import SwiftUI

struct EntryView: View {
  let persistenceController = PersistenceController.shared

  var body: some View {
    PhotoAssetListPage()
      .environment(\.managedObjectContext, persistenceController.container.viewContext)
  }
}

