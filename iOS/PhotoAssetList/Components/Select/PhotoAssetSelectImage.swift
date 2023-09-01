import SwiftUI

struct PhotoAssetSelectImage: View {
  @Environment(\.screenSize) var screenSize
  let asset: Asset
  let photo: Photo?
  let tags: [Tag]
  @Binding var isSelected: Bool

  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      AsyncAssetImage(asset: asset, maxImageLength: screenSize.width / 3 - 2) { image in
          image
            .resizable()
            .scaledToFill()
            .frame(width: screenSize.width, height: screenSize.height)
            .clipped()
      } placeholder: {
          Image(systemName: "photo")
      }

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

