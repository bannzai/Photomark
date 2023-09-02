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
      VStack {
        ForEach(0..<sections.count, id: \.self) { i in
          let section = sections[i]
          sectionHeader(section)

          LazyVGrid(columns: gridItems()) {
            ForEach(section.assets, id: \.localIdentifier) { asset in
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
