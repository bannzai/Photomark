import SwiftUI

@main
struct PhotomarkApp: App {
  let persistenceController = PersistenceController.shared

  var body: some Scene {
    WindowGroup {
      NavigationView {
        PhotoAssetListPage()
          .environmentObject(AppViewModel())
          .environment(\.managedObjectContext, persistenceController.container.viewContext)
      }
    }
  }
}
