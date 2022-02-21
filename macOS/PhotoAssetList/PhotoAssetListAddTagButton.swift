import SwiftUI

struct PhotoAssetListAddTagButton: View {
  @Environment(\.photoLibrary) private var photoLibrary
  @Environment(\.managedObjectContext) private var viewContext

  let asset: Asset
  var photo: Photo?

  @State var photoState: Photo?
  @State var error: Error?

  var body: some View {
    Button(action: {
      if let photo = photo {
        photoState = photo
      } else {
        do {
          photoState = try Photo.createAndSave(context: viewContext, asset: asset)
        } catch {
          self.error = error
        }
      }
    }) {
      Image(systemName: "plus")
    }
    .handle(error: $error)
  }
}

