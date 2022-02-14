import SwiftUI

struct EntryView: View {
  let persistenceController = PersistenceController.shared

  var body: some View {
      NavigationView {
        PhotoAssetListPage()
          .environment(\.managedObjectContext, persistenceController.container.viewContext)
      }
  }
}

