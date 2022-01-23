import SwiftUI

struct GridAssetImageFrame<Content: View>: View {
  @ViewBuilder let content: (GeometryProxy) -> Content

  var body: some View {
    GeometryReader { gridItemGeometry in
      content(gridItemGeometry)
    }
    // NOTE: Workaround for avoid the problem of images retrieved from phasset being overflowed.
    .clipped()
    .aspectRatio(1, contentMode: .fit)
  }
}
