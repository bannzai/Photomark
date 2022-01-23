import SwiftUI
import CoreData
import Photos
import UniformTypeIdentifiers
import PhotosUI

struct PhotoAssetListPage: View {
  @Environment(\.photoLibrary) private var photoLibrary
  @Environment(\.managedObjectContext) private var viewContext

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Photo.createdDate, ascending: false)],
    animation: .default)
  private var photos: FetchedResults<Photo>
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Tag.createdDate, ascending: false)],
    animation: .default)
  private var tags: FetchedResults<Tag>

  @State var assets: [Asset] = []
  @State var error: Error?
  @State var searchText: String = ""
  @State var selectedTags: [Tag] = []
  @State var alertType: AlertType?

  enum AlertType: Identifiable {
    case openSetting
    case noPermission

    var id: Self { self }
  }

  private let gridItems: [GridItem] = [
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
  ]
  private var filteredAssets: [Asset] {
    if selectedTags.isEmpty {
      return assets
    } else {
      return assets.filter { asset in
        photos.filter { photo in
          guard let photoTagIDs = photo.tagIDs else {
            return false
          }

          return photoTagIDs.contains { photoTagID in
            selectedTags.contains { tag in
              tag.id?.uuidString == photoTagID
            }
          }
        }
        .contains { $0.phAssetIdentifier == asset.id }
      }
    }
  }

  var body: some View {
    GeometryReader { viewGeometry in
      Group {
        if assets.isEmpty {
          VStack(alignment: .center, spacing: 10) {
            Spacer()
            Text("写真が存在しません")
            Spacer()
          }
          .ignoresSafeArea()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .navigationBarHidden(true)
        } else {
          ScrollView(.vertical) {
            VStack {
              TagLine(tags: tags.toArray()) { tag in
                TagView(tag: tag, isSelected: selectedTags.contains(tag))
                  .onTapGesture {
                    if selectedTags.contains(tag) {
                      selectedTags.removeAll { $0.id == tag.id }
                    } else {
                      selectedTags.append(tag)
                    }
                  }
              }

              LazyVGrid(columns: gridItems, spacing: 1) {
                ForEach(filteredAssets) { asset in
                  PhotoAssetImage(
                    asset: asset,
                    photo: photos.first(where: { $0.phAssetIdentifier == asset.id }),
                    tags: tags.toArray()
                  )
                }
              }
            }
          }
          .navigationTitle("保存済み")
          .navigationBarTitleDisplayMode(.inline)
          .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "検索")
        }
      }
      .task {
        switch photoLibrary.authorizationAction() {
        case .requestAuthorization:
          let status = await photoLibrary.requestAuthorization()
          switch status {
          case .authorized, .limited:
            await fetchAll(viewGeometry: viewGeometry)
          case .notDetermined, .restricted, .denied:
            alertType = .noPermission
          @unknown default:
            assertionFailure("New case \(status)")
          }
        case .openSettingApp:
          alertType = .openSetting
        case nil:
          await fetchAll(viewGeometry: viewGeometry)
        }
      }
      .alert(item: $alertType, content: { alertType in
        switch alertType {
        case .openSetting:
          return Alert(
            title: Text("画像を選択できません"),
            message: Text("フォトライブラリのアクセスが許可されていません。設定アプリから許可をしてください"),
            primaryButton: .default(Text("設定を開く"), action: openSetting),
            secondaryButton: .cancel()
          )
        case .noPermission:
          return Alert(
            title: Text("アクセスを拒否しました"),
            message: Text("フォトライブラリのアクセスが拒否されました。操作を続ける場合は設定アプリから許可をしてください"),
            primaryButton: .default(Text("設定を開く"), action: openSetting),
            secondaryButton: .cancel()
          )
        }
      })
      .handle(error: $error)
    }
  }

  // TODO: No blocking code
  func fetchAll(viewGeometry: GeometryProxy) async {
    let phAssets = photoLibrary.fetchAssets().assets()
    let sortedAssets = phAssets.sorted { lhs, rhs in
      if let l = lhs.creationDate?.timeIntervalSinceReferenceDate, let r = rhs.creationDate?.timeIntervalSinceReferenceDate {
        return l > r
      } else {
        assertionFailure()
        return false
      }
    }

    for phAsset in sortedAssets {
      if let response = await photoLibrary.firstAsset(phAsset: phAsset, maxImageLength: viewGeometry.size.width / 3) {
        assets.append(response)
      }
    }
  }
}

private func openSetting() {
  let settingURL = URL(string: UIApplication.openSettingsURLString)!
  if UIApplication.shared.canOpenURL(settingURL) {
    UIApplication.shared.open(settingURL)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var viewContext: NSManagedObjectContext { PersistenceController.preview.container.viewContext }

  static var previews: some View {
    Group {
      PhotoAssetListPage()
      PhotoAssetListPage()
        .onAppear {
          let photo = Photo(context: viewContext)
          photo.id = .init()
          try! viewContext.save()
        }
    }
  }
}
