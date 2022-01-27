import SwiftUI

struct PhotoAssetSelectGrid: View {
  let assets: [Asset]
  let photos: [Photo]
  let tags: [Tag]
  let sections: [AssetSection]

  init(assets: [Asset], photos: [Photo], tags: [Tag]) {
    self.assets = assets
    self.photos = photos
    self.tags = tags

    sections = assets.reduce(into: [AssetSection]()) { partialResult, asset in
      guard let assetCreationDate = asset.asset.creationDate else {
        return
      }

      if let lastSection = partialResult.last {
        var section = lastSection

        if section.end < assetCreationDate {
          section.end = assetCreationDate
        }

        if !Calendar.current.isDate(section.start, inSameDayAs: assetCreationDate) {
          if section.assets.count > 8 {
            let newSection = AssetSection(start: assetCreationDate, end: assetCreationDate, assets: [asset])
            partialResult.append(newSection)
            return
          }
        }

        section.assets.append(asset)
        partialResult[partialResult.count - 1] = section

      } else {
        let section = AssetSection(start: assetCreationDate, end: assetCreationDate, assets: [asset])
        partialResult.append(section)
      }
    }
  }

  private let gridItems: [GridItem] = [
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
  ]

  struct AssetSection {
    var start: Date
    var end: Date
    var assets: [Asset]

    var interval: DateInterval {
      .init(start: start, end: end)
    }
  }

  let sectionHeaderFomatter: DateIntervalFormatter = {
    let formatter = DateIntervalFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
  }()

  var body: some View {
    VStack(spacing: 8) {
      ForEach(0..<sections.count) { i in
        // FIXME: cause out of index when filtering with photo tags
        if i <= sections.count - 1 {
          let section = sections[i]

          LazyVGrid(columns: gridItems, spacing: 1) {
            Section(header: sectionHeader(section)) {
              ForEach(section.assets) { asset in
                GridAssetImageGeometryReader { gridItemGeometry in
                  PhotoAssetImage(
                    asset: asset,
                    photo: photos.first(where: { $0.phAssetIdentifier == asset.id }),
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
