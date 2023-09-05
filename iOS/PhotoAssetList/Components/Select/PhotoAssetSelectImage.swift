import SwiftUI

struct PhotoAssetSelectImage: View {
  @Environment(\.screenSize) var screenSize
  let asset: Asset
  let photo: Photo?
  let tags: [Tag]
  @Binding var isSelected: Bool

  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      let width = screenSize.width / 3 - 2
      AsyncAssetImage(asset: asset, maxImageLength: width) { image in
          image
            .resizable()
            .scaledToFill()
            .clipped()
      } placeholder: {
          Image(systemName: "photo")
      }
      .frame(width: width, height: width)

      Group {
        if isSelected {
          Image(systemName: "checkmark.circle.fill")
        } else {
          Image(systemName: "circle")
        }
      }
      .symbolRenderingMode(.monochrome)
      .foregroundStyle(.blue)
      .frame(width: 32, height: 32)
    }
    .onTapGesture {
      isSelected.toggle()
    }
  }
}

