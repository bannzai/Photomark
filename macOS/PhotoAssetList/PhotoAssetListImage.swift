import SwiftUI

struct PhotoAssetListImage: View {
  @Environment(\.managedObjectContext) private var viewContext

  let asset: Asset
  let photo: Photo?
  let tags: [Tag]

  struct SelectedElement: Hashable {
    let photo: Photo
    let asset: Asset
  }
  @State var selectedElement: SelectedElement?
  @State var error: Error?

  private var transitionToDetail: Binding<Bool>  {
    .init {
      selectedElement != nil
    } set: { _ in
      selectedElement = nil
    }
  }

  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      AsyncAssetImage(asset: asset) { image in
        image
          .resizable()
          .scaledToFill()
          .clipped()
      } placeholder: {
        Image(systemName: "photo")
      }

      AssetCopyButton(asset: asset)
        .frame(width: 32, height: 32)
    }
    .sheet(isPresented: transitionToDetail, onDismiss: nil, content: {
      if let element = selectedElement {
        PhotoDetailPage(asset: element.asset, photo: element.photo, tags: tags)
          .environment(\.managedObjectContext, viewContext)
      }
    })
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
