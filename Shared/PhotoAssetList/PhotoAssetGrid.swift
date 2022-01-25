import SwiftUI

struct PhotoAssetGrid: View {
  let assets: [Asset]
  let photos: [Photo]
  let tags: [Tag]

  private let gridItems: [GridItem] = [
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
  ]

  var body: some View {
    LazyVGrid(columns: gridItems, spacing: 1) {
      ForEach(assets) { asset in
        GridAssetImageGeometryReader { gridItemGeometry in
          PhotoAssetImage(
            asset: asset,
            photo: photos.first(where: { $0.phAssetIdentifier == asset.id }),
            tags: tags,
            maxImageLength: gridItemGeometry.size.width
          )
            .scaledToFill()
            .frame(width: gridItemGeometry.size.width, height: gridItemGeometry.size.height)
        }
      }
    }
  }
}
