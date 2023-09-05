import SwiftUI

struct AssetCopyButton: View {
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
        Image(systemName: "doc.on.doc")
          .onTapGesture {
            isDownloading = true

            Task { @MainActor in
              if let image = await photoLibrary.highQualityImage(for: asset) {
                Pasteboard.general.image = image

                if let photo {
                  photo.lastCopiedDateTime = .now
                  try viewContext.save()
                } else {
                  let photo = try Photo.createAndSave(context: viewContext, asset: asset)
                  photo.lastCopiedDateTime = .now
                  try viewContext.save()
                }

                // Delay for user can recognize ProgressView.
                try? await Task.sleep(nanoseconds: 2 * (NSEC_PER_SEC / 10))
                isDownloading = false
              } else {
                error = AlertError("画像を保存できませんでした", "再度お試しください")
              }
            }
          }
      }
    }
    .handle(error: $error)
  }
}
