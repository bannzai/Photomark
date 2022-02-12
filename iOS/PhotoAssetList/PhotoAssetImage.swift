import SwiftUI


struct PhotoAssetImage: View {
  @Environment(\.managedObjectContext) private var viewContext

  let asset: Asset
  let tags: [Tag]
  let maxImageLength: CGFloat

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

      AssetCopyButton(asset: asset)
        .frame(width: 32, height: 32)
    }
  }
}
