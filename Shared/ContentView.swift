import SwiftUI
import CoreData
import Photos

struct ContentView: View {
  @Environment(\.photoLibrary) private var photoLibrary
  @Environment(\.managedObjectContext) private var viewContext

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Photo.createdDate, ascending: true)],
    animation: .default)
  private var photos: FetchedResults<Photo>
  @State var assets: [PhotoLibrary.AssetResponse] = []

  @State var isPhotoLibraryAssetListPresented: Bool = false

  private let gridItems: [GridItem] = [
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
  ]

  var body: some View {
    NavigationView {
      GeometryReader { viewGeometry in
        ScrollView(.vertical) {
          LazyVGrid(columns: gridItems, spacing: 1) {
            ForEach(assets) { asset in
              GridImage(response: asset)
            }
          }
        }
        .task {
          let phAssets = Array(photoLibrary.fetchAssets().assets()[0..<40])
          for phAsset in phAssets {
            Task { @MainActor in
              for await response in photoLibrary.imageStream(for: phAsset, maxImageLength: viewGeometry.size.width / 3) {
                assets.append(response)
              }
            }
          }
        }
        .toolbar {
          ToolbarItem {
            Button(action: {
              isPhotoLibraryAssetListPresented = true
            }) {
              Label("Add Item", systemImage: "plus")
            }
          }
        }
        .sheet(isPresented: $isPhotoLibraryAssetListPresented) {
          PhotoLibraryAssetList()
        }
      }
    }
  }

  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      offsets.map { photos[$0] }.forEach(viewContext.delete)

      do {
        try viewContext.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
      }
    }
  }
}

private let itemFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateStyle = .short
  formatter.timeStyle = .medium
  return formatter
}()

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
