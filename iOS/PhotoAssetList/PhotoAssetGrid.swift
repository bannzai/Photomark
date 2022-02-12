import SwiftUI

struct PhotoAssetGrid: View {
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


  private let gridItems: [GridItem] = [
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
  ]

  let sectionHeaderFomatter: DateIntervalFormatter = {
    let formatter = DateIntervalFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
  }()

  var body: some View {
    ZStack {
      List {
        ForEach(0..<sections.count) { i in
          // FIXME: cause out of index when filtering with photo tags
          if i <= sections.count - 1 {
            let section = sections[i]

            LazyVGrid(columns: gridItems, spacing: 1) {
              Section(header: sectionHeader(section)) {
                ForEach(section.assets) { asset in
                  let photo = photos.first(where: { $0.phAssetIdentifier == asset.id })

                  GridAssetImageGeometryReader { gridItemGeometry in
                    PhotoAssetImage(
                      asset: asset,
                      photo: photo,
                      tags: tags,
                      maxImageLength: gridItemGeometry.size.width
                    )
                  }
                }
              }
            }
          }
        }
      }
      .listStyle(.plain)
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
