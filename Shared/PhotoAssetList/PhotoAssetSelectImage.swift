import SwiftUI

struct PhotoAssetSelectImage: View {
  @Environment(\.photoLibrary) private var photoLibrary
  @Environment(\.managedObjectContext) private var viewContext

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

      if isSelected {
        Image(systemName: "checkmark.circle.fill")
      } else {
        Image(systemName: "circle")
      }
    }
    .onTapGesture {
      isSelected.toggle()
    }
  }
}

