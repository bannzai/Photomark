import SwiftUI

struct PhotoAssetListImage: View {
  @Environment(\.managedObjectContext) private var viewContext

  let asset: Asset
  let photo: Photo?
  let tags: [Tag]
  let maxImageLength: CGFloat

  struct SelectedElement: Hashable {
    let photo: Photo
    let asset: Asset
  }
  @State var selectedElement: SelectedElement?
  @State var error: Error?

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

      HStack {
        PhotoAssetListAddTagButton(asset: asset, photo: photo)
        AssetCopyButton(asset: asset)
          .frame(width: 32, height: 32)
      }
    }
    .frame(width: maxImageLength, height: maxImageLength)
    .onTapGesture {
      if let photo = photo {
        selectedElement = .init(photo: photo, asset: asset)
      } else {
        do {
          selectedElement = .init(
            photo: try Photo.createAndSave(context: viewContext, asset: asset),
            asset: asset
          )
        } catch {
          self.error = error
        }
      }
    }
    .handle(error: $error)
  }
}
