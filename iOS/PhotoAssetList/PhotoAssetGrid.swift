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

  struct SelectedElement: Hashable {
    let photo: Photo
    let asset: Asset
  }
  @State var selectedElement: SelectedElement?
  @State var error: Error?

  private var transitionToDetail: Binding<Bool>  {
    .init {
      selectedElement != nil
    } set: { _ in
      selectedElement = nil
    }
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
      NavigationLink(isActive: transitionToDetail) {
        if let element = selectedElement {
          PhotoDetailPage(asset: element.asset, photo: element.photo, tags: tags)
        }
      } label: {
        EmptyView()
      }

      List(selection: $selectedElement) {
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
                      tags: tags,
                      maxImageLength: gridItemGeometry.size.width
                    )
                    .frame(width: gridItemGeometry.size.width, height: gridItemGeometry.size.height)
                    .onTapGesture {
                      if let photo = photo {
                        selectedElement = .init(photo: photo, asset: asset)
                      } else {
                        do {
                          selectedElement = .init(
                            photo: try Photo.createAndSave(context: viewContext, asset: asset),
                            asset: asset
                          )
                        } catch {
                          self.error = error
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      .listStyle(.plain)
      .handle(error: $error)
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
