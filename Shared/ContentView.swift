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

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let imageLength = geometry.size.width / 3

                List {
                    ForEach(assets) { asset in
                        if let image = asset.image {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: imageLength, height: imageLength)
                        } else {
                            Text("Image Not found")
                        }
                    }
                    .onDelete(perform: deleteItems)

                    Text("Select an item")
                }
                .task {
                    let phAssets = Array(photoLibrary.fetchAssets().assets()[0..<40])
                    for phAsset in phAssets {
                        Task { @MainActor in
                            for await response in photoLibrary.imageStream(for: phAsset, imageLength: imageLength) {
                                assets.append(response)
                            }
                        }
                    }
                }
                .toolbar {
#if os(iOS)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
#endif
                    ToolbarItem {
                        Button(action: addItem) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Photo(context: viewContext)
            newItem.createdDate = Date()

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
