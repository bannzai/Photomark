import SwiftUI

struct AssetDownloadButton: View {
  @Environment(\.photoLibrary) var photoLibrary
  let asset: Asset

  @State var isDownloading: Bool = false
  @State var error: Error?

  var body: some View {
    Group {
      if isDownloading {
        ProgressView()
      } else {
        Button(action: {
          isDownloading = true
          Task { @MainActor in
            if let image = await photoLibrary.highQualityImage(for: asset) {
              UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

              // Delay for user can recognize ProgressView.
              await Task.sleep(2 * (NSEC_PER_SEC / 10))
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
