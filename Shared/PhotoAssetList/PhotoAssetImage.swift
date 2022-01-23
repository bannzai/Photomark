import SwiftUI

struct PhotoAssetImage: View {
  @EnvironmentObject var appViewModel: AppViewModel
  @Environment(\.managedObjectContext) private var viewContext

  let asset: Asset
  let photoID: Photo.ID?

  @State var editingPhoto: Photo? = nil
  @State var error: Error?

  var photo: Photo? {
    guard let photoID = photoID else {
      return nil
    }
    return appViewModel.photo(id: photoID)
  }

  var body: some View {
    if let image = asset.image {
      GridImage(image: image)
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
          PhotoEditPage(image: image, photoID: photo.id)
        }
        .handle(error: $error)
    }
  }
}
