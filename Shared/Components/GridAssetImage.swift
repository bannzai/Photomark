import SwiftUI

struct GridAssetImage: View {
  let asset: Asset
  
  // NOTE: Workaround for avoid the problem of images retrieved from phasset being overflowed.
  var body: some View {
    GeometryReader { gridItemGeometry in
      AssetAsyncImage<_ConditionalContent<Image, Image>>(asset: asset) { phase in
        switch phase {
        case .empty:
          Image(systemName: "photo")
            .resizable()
        case let .success(image):
          image
            .resizable()
        }
      }
      .scaledToFill()
      .frame(width: gridItemGeometry.size.width, height: gridItemGeometry.size.height)
    }
    .clipped()
    .aspectRatio(1, contentMode: .fit)
  }
}

