import SwiftUI

struct PhotoAssetListAddTagButton: View {
  @Environment(\.photoLibrary) private var photoLibrary
  @Environment(\.managedObjectContext) private var viewContext

  let asset: Asset
  var photo: Photo?

  @State var showsApplyTagPage = false

  var body: some View {
    NavigationLink {
      ApplyTagPage(targetAssets: [asset]) {
        // NONE
      }
    } label: {
      Image(systemName: "plus")
    }
  }
}

