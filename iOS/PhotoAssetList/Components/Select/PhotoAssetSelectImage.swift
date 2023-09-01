import SwiftUI

struct PhotoAssetSelectImage: View {
  let asset: Asset
  let photo: Photo?
  let tags: [Tag]
  @Binding var isSelected: Bool

  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      AsyncAssetImage(asset: asset) { image in
          image
            .resizable()
            .scaledToFill()
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

