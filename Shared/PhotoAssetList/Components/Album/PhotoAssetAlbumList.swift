import SwiftUI

struct PhotoAssetAlbumList: View {
  let albums: [Album]

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 10) {
        ForEach(albums) { album in
          if let asset = album.firstAsset {
            VStack(spacing: 4) {
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
                .font(.system(size: 12))
            }
          }
        }
      }
      .padding(.horizontal, 10)
    }
  }
}
