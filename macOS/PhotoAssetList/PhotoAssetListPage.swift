import SwiftUI
import CoreData
import Photos
import UniformTypeIdentifiers
import PhotosUI

struct PhotoAssetListPage: View {
  @Environment(\.photoLibrary) var photoLibrary
  @Environment(\.managedObjectContext) var viewContext

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Photo.createdDate, ascending: false)],
    animation: .default)
  var photos: FetchedResults<Photo>
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Tag.createdDate, ascending: false)],
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
        .searchable(text: $searchText, placement: .toolbar, prompt: "検索")
        .toolbar(content: {
          ToolbarItem(placement: .navigation) {
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
    .frame(minWidth:  400)
  }
}
