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
    List {
      ForEach(0..<sections.count) { i in
        let section = sections[i]

        LazyVGrid(columns: gridItems()) {
          Section(header: sectionHeader(section)) {
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
      .listRowInsets(.init())
      .listRowSeparator(.hidden)
    }
    .listStyle(.plain)
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
