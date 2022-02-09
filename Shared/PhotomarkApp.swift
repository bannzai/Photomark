import SwiftUI

@main
struct PhotomarkApp: App {
  let persistenceController = PersistenceController.shared

  var body: some Scene {
    WindowGroup {
      NavigationView {
        PhotoAssetListPage()
          .environment(\.managedObjectContext, persistenceController.container.viewContext)
      }
      .navigationViewStyle(.stack)
    }
  }
}
