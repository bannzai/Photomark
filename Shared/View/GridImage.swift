import SwiftUI
import Photos

struct GridImage: View {
  let response: PhotoLibrary.AssetResponse
  
  // NOTE: Workaround for avoid the problem of images retrieved from phasset being overflowed.
  var body: some View {
    if let image = response.image {
      GeometryReader { gridItemGeometry in
        Image(uiImage: image)
          .resizable()
          .scaledToFill()
          .frame(width: gridItemGeometry.size.width, height: gridItemGeometry.size.height)
      }
      .clipped()
      .aspectRatio(1, contentMode: .fit)
    }
  }
}

