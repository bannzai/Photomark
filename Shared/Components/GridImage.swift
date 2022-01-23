import SwiftUI

struct GridImage: View {
  let image: UIImage
  
  // NOTE: Workaround for avoid the problem of images retrieved from phasset being overflowed.
  var body: some View {
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

