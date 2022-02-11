import SwiftUI


struct PhotoAssetImage: View {
  @Environment(\.photoLibrary) private var photoLibrary
  @Environment(\.managedObjectContext) private var viewContext

  let asset: Asset
  let photo: Photo?
  let tags: [Tag]
  let maxImageLength: CGFloat

  @State var editingPhoto: Photo? = nil
  @State var error: Error?

  var transitionedToDetail: Binding<Bool> {
    .init {
      editingPhoto != nil
    } set: { _ in
      editingPhoto = nil
    }
  }


  var body: some View {
    NavigationLink(isActive: transitionedToDetail) {
      if let photo = editingPhoto {
        PhotoDetailPage(asset: asset, photo: photo, tags: tags)
      }
    } label: {
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

        AssetCopyButton(asset: asset)
          .frame(width: 32, height: 32)
      }
      .onTapGesture {
        if let photo = photo {
          editingPhoto = photo
        } else {
          do {
            editingPhoto = try Photo.createAndSave(context: viewContext, asset: asset)
          } catch {
            self.error = error
          }
        }
      }
      .handle(error: $error)
    }
  }
}
