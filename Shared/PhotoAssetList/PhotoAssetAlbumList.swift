import SwiftUI

struct PhotoAssetAlbumList: View {
  let albums: [Album]

  var body: some View {
    ScrollView(.horizontal) {
      HStack {
        ForEach(albums) { album in
          if let asset = album.firstAsset {
            VStack(spacing: 8) {
              AsyncAssetImage(
                asset: asset,
                maxImageLength: 100,
                content: { image in
                  image
                    .resizable()
                },
                placeholder: {
                  Image(systemName: "photo")
                })
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipped()

              Text(verbatim: album.collection.localizedTitle ?? "No Title")
            }
          }
        }
      }
      .padding(.horizontal, 10)
    }
  }
}
