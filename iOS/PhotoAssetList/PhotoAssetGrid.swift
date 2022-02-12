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

  @State var selectedPhoto: Photo?
  @State var error: Error?

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
    List(selection: $selectedPhoto) {
      ForEach(0..<sections.count) { i in
        // FIXME: cause out of index when filtering with photo tags
        if i <= sections.count - 1 {
          let section = sections[i]

          LazyVGrid(columns: gridItems, spacing: 1) {
            Section(header: sectionHeader(section)) {
              ForEach(section.assets) { asset in
                let photo = photos.first(where: { $0.phAssetIdentifier == asset.id })

                ZStack {
                  NavigationLink(isActive: .constant(
                    selectedPhoto != nil && selectedPhoto?.id == photo?.id
                  )) {
                    if let photo = selectedPhoto {
                      PhotoDetailPage(asset: asset, photo: photo, tags: tags)
                    }
                  } label: {
                    EmptyView()
                  }

                  Button {
                    if let photo = photo {
                      selectedPhoto = photo
                    } else {
                      do {
                        selectedPhoto = try Photo.createAndSave(context: viewContext, asset: asset)
                      } catch {
                        self.error = error
                      }
                    }
                  } label: {
                    GridAssetImageGeometryReader { gridItemGeometry in
                      PhotoAssetImage(
                        asset: asset,
                        tags: tags,
                        maxImageLength: gridItemGeometry.size.width
                      )
                      .frame(width: gridItemGeometry.size.width, height: gridItemGeometry.size.height)
                    }
                  }
                }
                .handle(error: $error)
              }
            }
          }
        }
      }
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
