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

  @State var showsPhotoLibraryAssetList: Bool = false

  private let gridItems: [GridItem] = [
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
  ]

  var body: some View {
    GeometryReader { viewGeometry in
      if photos.isEmpty {
        VStack(alignment: .center, spacing: 10) {
          Button(action: {
            showsPhotoLibraryAssetList = true
          }, label: {
            Image(systemName: "plus")
              .font(.system(size: 40))
              .padding()
              .foregroundColor(.black)
              .overlay(Circle().stroke(Color.black))
          })

          Text("画像を追加しよう")
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        ScrollView(.vertical) {
          LazyVGrid(columns: gridItems, spacing: 1) {
            ForEach(photos) { photo in
              if let imageData = photo.imageData, let image = UIImage(data: imageData) {
                GridImage(image: image)
              }
            }
          }
        }
        .toolbar {
          ToolbarItem {
            Button(action: {
              showsPhotoLibraryAssetList = true
            }) {
              Label("Add Item", systemImage: "plus")
            }
          }
        }
      }
    }
    .sheet(isPresented: $showsPhotoLibraryAssetList) {
      PhotoLibraryAssetList()
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
    ContentView()
  }
}
