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
  @State var isDownloading: Bool = false

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
      .frame(width: maxImageLength, height: maxImageLength)

      Group {
        if isDownloading {
          ProgressView()
        } else {
          Button(action: {
            isDownloading = true
            Task { @MainActor in
              if let image = await photoLibrary.highQualityImage(for: asset) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                isDownloading = false
              } else {
                error = AlertError("画像を保存できませんでした", "再度お試しください")
              }
            }
          }) {
            Image(systemName: "arrow.down.circle")
              .padding(4)
          }
        }
      }
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
    .sheet(item: $editingPhoto) { photo in
      NavigationView {
        PhotoDetailPage(asset: asset, photo: photo, tags: tags)
      }
    }
    .handle(error: $error)
  }
}
