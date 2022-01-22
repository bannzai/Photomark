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
      let imageLength = geometry.size.width / 3

      LazyVGrid(columns: gridItems) {
        ForEach(assets) { asset in
          if let image = asset.image {
            Image(uiImage: image)
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: imageLength, height: imageLength)
          } else {
            Text("Image Not found")
          }
        }

      }
      .task {
        let phAssets = Array(photoLibrary.fetchAssets().assets()[0..<40])
        for phAsset in phAssets {
          Task { @MainActor in
            for await response in photoLibrary.imageStream(for: phAsset, maxImageLength: imageLength) {
              assets.append(response)
            }
          }
        }
      }
    }
  }
}

