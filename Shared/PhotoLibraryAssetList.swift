import SwiftUI

struct PhotoLibraryAssetList: View {
  @Environment(\.photoLibrary) private var photoLibrary
  @Environment(\.managedObjectContext) private var viewContext

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Photo.createdDate, ascending: true)],
    animation: .default)
  private var photos: FetchedResults<Photo>
  @State var assets: [PhotoLibrary.AssetResponse] = []

  private let gridItems: [GridItem] = [
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
  ]

  var body: some View {
    GeometryReader { geometry in
      GeometryReader { viewGeometry in
        ScrollView(.vertical) {
          LazyVGrid(columns: gridItems, spacing: 1) {
            ForEach(assets) { asset in
              if let image = asset.image {
                GridImage(image: image)
              }
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
      }
    }
  }
}

