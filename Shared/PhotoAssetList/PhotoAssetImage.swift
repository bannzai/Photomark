import SwiftUI

struct PhotoAssetImage: View {
  @Environment(\.managedObjectContext) private var viewContext

  let asset: Asset
  let photo: Photo?
  let tags: [Tag]
  let maxImageLength: CGFloat

  @State var editingPhoto: Photo? = nil
  @State var error: Error?

  var body: some View {
    AsyncAssetImage<_ConditionalContent<Image, Image>>(asset: asset, maxImageLength: maxImageLength) { phase in
      switch phase {
      case .empty:
        Image(systemName: "photo")
      case let .success(image):
        image
          .resizable()
      }
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
    .sheet(item: $editingPhoto) { photo in
      NavigationView {
        PhotoDetailPage(asset: asset, photo: photo, tags: tags)
      }
    }
    .handle(error: $error)
  }
}
