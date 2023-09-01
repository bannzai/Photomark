import SwiftUI

struct PhotoAssetListGrid: View {
  @Environment(\.managedObjectContext) private var viewContext

  let assets: [Asset]
  let photos: [Photo]
  let tags: [Tag]
  let sections: [AssetSection]
  init(assets: [Asset], photos: [Photo], tags: [Tag]) {
    self.assets = assets
    self.photos = photos
    self.tags = tags
    self.sections = createSections(assets: assets, photos: photos, tags: tags)
  }

  let sectionHeaderFomatter: DateIntervalFormatter = {
    let formatter = DateIntervalFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
  }()

  var body: some View {
    ScrollView(.vertical) {
      // LazyVGridだと画像領域が見えないところではみ出て、画像のタップイベントが他の画像に吸われたりする
      Grid(horizontalSpacing: 1, verticalSpacing: 1) {
        ForEach(0..<sections.count) { i in
          let section = sections[i]
          sectionHeader(section)

          let chunked = section.assets.chunked(by: 3)
          ForEach(chunked.indices) { index in
            GridRow {
              ForEach(chunked[index], id: \.localIdentifier) { asset in
                let photo = photos.first(where: { asset.cloudIdentifier == $0.phAssetCloudIdentifier })
                PhotoAssetListImage(
                  asset: asset,
                  photo: photo,
                  tags: tags
                )
              }
            }
          }
        }
      }
    }
  }

  private func sectionHeader(_ section: AssetSection) -> some View {
    HStack {
      Text(section.interval, formatter: sectionHeaderFomatter)
        .font(.system(size: 16))
        .bold()
      Spacer()
    }
    .padding(.top, 12)
    .padding(.bottom, 8)
  }
}
