import SwiftUI

struct PhotoAssetImage: View {
  @Environment(\.managedObjectContext) private var viewContext

  let asset: Asset
  let photo: Photo?
  let tags: [Tag]
  @Binding var dragAmount: (startLocation: CGPoint, transiton: CGSize)

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
        .sheet(item: $editingPhoto) { photo in
          PhotoEditPage(image: image, photo: photo, tags: tags)
        }
        .handle(error: $error)
    }
  }
}
