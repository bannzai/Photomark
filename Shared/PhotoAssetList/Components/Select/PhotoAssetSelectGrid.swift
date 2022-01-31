import SwiftUI

struct PhotoAssetSelectGrid: View {
  let assets: [Asset]
  let photos: [Photo]
  let tags: [Tag]
  let sections: [AssetSection]

  @State var selectedAssets: [Asset] = []
  @State var showsApplyTagPage = false

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
    VStack(spacing: 8) {
      ForEach(0..<sections.count) { i in
        // FIXME: cause out of index when filtering with photo tags
        if i <= sections.count - 1 {
          let section = sections[i]

          LazyVGrid(columns: gridItems, spacing: 1) {
            Section(header: sectionHeader(section)) {
              ForEach(section.assets) { asset in
                GridAssetImageGeometryReader { gridItemGeometry in
                  PhotoAssetSelectImage(
                    asset: asset,
                    photo: photos.first(where: { $0.phAssetIdentifier == asset.id }),
                    tags: tags,
                    maxImageLength: gridItemGeometry.size.width,
                    isSelected: .init(get: { selectedAssets.contains(asset) }, set: { isSelected in
                      if isSelected {
                        selectedAssets.append(asset)
                      } else {
                        selectedAssets.removeAll(where: { $0 == asset })
                      }
                    })
                  )
                }
              }
            }
          }
        }
      }
    }
    .sheet(isPresented: $showsApplyTagPage, content: {
      NavigationView {
        ApplyTagPage(targetAssets: selectedAssets, onComplete: {
          selectedAssets = []
        })
      }
    })
    .toolbar(content: {
      ToolbarItem(placement: .navigationBarLeading) {
        Button(action: {
          showsApplyTagPage = true
        }) {
          Image(systemName: "bookmark")
        }
      }
    })
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
