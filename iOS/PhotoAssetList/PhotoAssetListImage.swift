import SwiftUI

struct PhotoAssetListImage: View {
  @Environment(\.screenSize) var screenSize
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
      NavigationLink(isActive: transitionToDetail) {
        if let element = selectedElement {
          // Workaround for viewContext.save error
          PhotoDetailPage(asset: element.asset, photo: element.photo, tags: tags)
            .environment(\.managedObjectContext, viewContext)
        }
      } label: {
        EmptyView()
      }

      let width = screenSize.width / 3 - 2
      AsyncAssetImage(asset: asset, maxImageLength: width) { image in
        image
          .resizable()
          .scaledToFill()
          .frame(width: width, height: width)
          .clipped()
      } placeholder: {
        Image(systemName: "photo")
          .frame(width: width, height: width)
      }
      .frame(width: width, height: width)

      AssetCopyButton(asset: asset)
        .frame(width: 32, height: 32)
    }
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
