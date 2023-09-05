import SwiftUI

struct AssetDownloadButton: View {
  @Environment(\.photoLibrary) var photoLibrary
  @Environment(\.managedObjectContext) var viewContext

  @State var isDownloading: Bool = false
  @State var error: Error?

  let asset: Asset
  let photo: Photo?

  var body: some View {
    Group {
      if isDownloading {
        ProgressView()
      } else {
        Button(action: {
          isDownloading = true
          
          Task { @MainActor in
            if let image = await photoLibrary.highQualityImage(for: asset) {
              do {
                try saveImageToPhotoLibrary(image: image)
              } catch {
                self.error = error
              }

              if let photo {
                photo.lastAssetDownloadedDateTime = .now
                try viewContext.save()
              }

              // Delay for user can recognize ProgressView.
              try await Task.sleep(nanoseconds: 2 * (NSEC_PER_SEC / 10))
              isDownloading = false
            } else {
              error = AlertError("画像を保存できませんでした", "再度お試しください")
            }
          }
        }) {
          Image(systemName: "arrow.down.circle")
        }
      }
    }
    .handle(error: $error)
  }
}
