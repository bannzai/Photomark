import SwiftUI

struct PhotoAssetImage: View {
  @Environment(\.managedObjectContext) private var viewContext

  let asset: Asset
  let photo: Photo?
  let tags: [Tag]
  let isSelected: Bool

  @State var editingPhoto: Photo? = nil
  @State var error: Error?

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
        .border(isSelected ? Color.pink : Color.clear)
        .sheet(item: $editingPhoto) { photo in
          PhotoEditPage(image: image, photo: photo, tags: tags)
        }
        .handle(error: $error)
    }
  }
}
