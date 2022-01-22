import SwiftUI

struct PhotoLibraryAssetList: View {
  @Environment(\.photoLibrary) private var photoLibrary

  @State var assets: [Asset] = []

  private let gridItems: [GridItem] = [
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
  ]
  
  var body: some View {
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

