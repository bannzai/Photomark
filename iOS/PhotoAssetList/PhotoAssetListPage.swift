import SwiftUI
import CoreData
import Photos
import UniformTypeIdentifiers
import PhotosUI

struct PhotoAssetListPage: View {
  @Environment(\.photoLibrary) var photoLibrary
  @Environment(\.managedObjectContext) var viewContext

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Photo.createdDateTime, ascending: false)],
    animation: .default)
  var photos: FetchedResults<Photo>
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Tag.createdDateTime, ascending: false)],
    animation: .default)
  var tags: FetchedResults<Tag>

  @State var assets: [Asset] = []
  @State var error: Error?
  @State var searchText: String = ""
  @State var selectedTags: [Tag] = []
  @State var alertType: AlertType?
  @State var isSelectingMode = false

  enum AlertType: Identifiable {
    case openSetting
    case noPermission

    var id: Self { self }
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
      } else {
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

          if isSelectingMode {
            PhotoAssetSelectGrid(assets: assets, photos: photos.toArray(), tags: tags.toArray())
          } else {
            PhotoAssetListGrid(assets: filteredAssets, photos: photos.toArray(), tags: tags.toArray())
          }
        }
        .navigationTitle("一覧")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "タグを検索")
        .toolbar(content: {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
              isSelectingMode.toggle()
            }) {
              Image(systemName: "checklist")
            }
          }
        })
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
}

extension PhotoAssetListPage {
  var filteredAssets: [Asset] {
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
          return tuple.photoTagIDs.contains { photoTagID in
            selectedTags.allSatisfy { $0.id?.uuidString == photoTagID }
          }
        } else {
          return true
        }
      }

      return assets.filter { asset in
        filteredPhotos.contains { tuple in asset.cloudIdentifier == tuple.photo.phAssetCloudIdentifier }
      }
    }
  }

  func fetchFirst() {
    let phAssets = photoLibrary.fetchAssets().toArray()
    let cloudIdentifiers = PHPhotoLibrary.shared().cloudIdentifierMappings(forLocalIdentifiers: phAssets.map(\.localIdentifier))
    assets = phAssets.compactMap { asset in
      guard let cloudIdentifier = try? cloudIdentifiers[asset.localIdentifier]?.get().stringValue else {
        return nil
      }
      return .init(phAsset: asset, cloudIdentifier: cloudIdentifier)
    }
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

