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

          LazyVGrid(columns: gridItems(), spacing: 1) {
            ForEach(section.assets, id: \.localIdentifier) { asset in
              PhotoAssetSelectImage(
                asset: asset,
                photo: photos.first(where: { asset.cloudIdentifier  == $0.phAssetCloudIdentifier }),
                tags: tags,
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
