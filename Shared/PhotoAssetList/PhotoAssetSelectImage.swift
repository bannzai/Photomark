import SwiftUI

struct PhotoAssetSelectImage: View {
  let asset: Asset
  let photo: Photo?
  let tags: [Tag]
  let maxImageLength: CGFloat
  @Binding var isSelected: Bool

  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      AsyncAssetImage(asset: asset, maxImageLength: maxImageLength) { image in
          image
            .resizable()
            .scaledToFill()
            .frame(width: maxImageLength, height: maxImageLength)
            .clipped()
      } placeholder: {
          Image(systemName: "photo")
      }
      .frame(width: maxImageLength, height: maxImageLength)

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

