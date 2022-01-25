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
  @State var albums: [Album] = []
  @State var error: Error?
  @State var searchText: String = ""
  @State var selectedTags: [Tag] = []
  @State var alertType: AlertType?

  enum AlertType: Identifiable {
    case openSetting
    case noPermission

    var id: Self { self }
  }

  private var filteredAssets: [Asset] {
    if selectedTags.isEmpty && searchText.isEmpty {
      return assets
    } else {
      let filteredPhotos: [(photo: Photo, photoTagIDs: [String])] = photos.toArray().compactMap { photo in
        if let tagIDs = photo.tagIDs {
          return (photo: photo, photoTagIDs: tagIDs)
        } else {
          return nil
        }
      }.filter { tuple in
        if !searchText.isEmpty {
          let filteredTags = tags.toArray().filtered(tagName: searchText)

          return tuple.photoTagIDs.contains { photoTagID in
            filteredTags.contains { $0.id?.uuidString == photoTagID }
          }
        } else {
          return true
        }
      }.filter { tuple in
        if !selectedTags.isEmpty {
          return selectedTags.contains { selectedTag in
            tuple.photoTagIDs.allSatisfy { photoTagID in
              selectedTag.id?.uuidString == photoTagID
            }
          }
        } else {
          return true
        }
      }

      return assets.filter { asset in
        filteredPhotos.contains { tuple in tuple.photo.phAssetIdentifier == asset.id }
      }
    }
  }

  var body: some View {
    Group {
      if assets.isEmpty {
        VStack(alignment: .center, spacing: 10) {
          Spacer()
          ProgressView("読み込み中...")
          Spacer()
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarHidden(true)
      } else {
        VStack(spacing: 12) {
          VStack(spacing: 8) {
            TagLine(tags: tags.toArray().filtered(tagName: searchText)) { tag in
              TagView(tag: tag, isSelected: selectedTags.contains(tag))
                .onTapGesture {
                  if selectedTags.contains(tag) {
                    selectedTags.removeAll { $0.id == tag.id }
                  } else {
                    selectedTags.append(tag)
                  }
                }
            }

            ScrollView(.vertical) {
              VStack(spacing: 12) {
                PhotoAssetAlbumList(albums: albums)
                PhotoAssetGrid(assets: filteredAssets, photos: photos.toArray(), tags: tags.toArray())
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
          fetchFirst()
        case .notDetermined, .restricted, .denied:
          alertType = .noPermission
        @unknown default:
          assertionFailure("New case \(status)")
        }
      case .openSettingApp:
        alertType = .openSetting
      case nil:
        fetchFirst()
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

  func fetchFirst() {
    let phAssets = photoLibrary.fetchAssets().toArray()
    let sortedAssets = phAssets.sorted { lhs, rhs in
      if let l = lhs.creationDate?.timeIntervalSinceReferenceDate, let r = rhs.creationDate?.timeIntervalSinceReferenceDate {
        return l > r
      } else {
        assertionFailure()
        return false
      }
    }
    assets = sortedAssets.map(Asset.init)

    let phAssetCollections = photoLibrary.fetchAssetCollection().toArray()
    let assetsInCollection = phAssetCollections.map(photoLibrary.fetchFirstAsset(in:))
    zip(phAssetCollections, assetsInCollection).forEach { (collection, asset) in
      if let asset = asset {
        albums.append(Album(collection: collection, firstAsset: Asset(phAsset: asset)))
      } else {
        albums.append(Album(collection: collection, firstAsset: nil))
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
