import SwiftUI

struct EntryView: View {
  let persistenceController = PersistenceController.shared

  var body: some View {
      NavigationView {
        PhotoAssetDateListPage()
          .environment(\.managedObjectContext, persistenceController.container.viewContext)
      }
  }
}

