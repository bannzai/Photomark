//
//  ContentView.swift
//  Shared
//
//  Created by 廣瀬雄大 on 2022/01/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.photoLibrary) private var photoLibrary
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Photo.createdDate, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Photo>
    @State private var assets: [PhotoLibrary.AssetResponse] = []


    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let edge = geometry.size.width / 3

                List {
                    ForEach(assets) { asset in
                        if let image = asset.image {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: edge, height: edge)
                        } else {
                            Text("Image Not found")
                        }
                    }
                    .onDelete(perform: deleteItems)

                    Text("Select an item")
                }
                .task {
                    for asset in photoLibrary.fetchAssets().assets().reversed()[0..<40] {
                        Task { @MainActor in
                            for await response in photoLibrary.imageStream(for: asset, edge: edge) {
                                print("[DEBUG]", "response: ", response)
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
            offsets.map { items[$0] }.forEach(viewContext.delete)

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
