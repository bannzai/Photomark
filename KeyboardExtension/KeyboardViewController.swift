//
//  KeyboardViewController.swift
//  KeyboardExtension
//
//  Created by bannzai on 2023/08/31.
//

import UIKit
import SwiftUI
import Photos

class KeyboardViewController: UIInputViewController {
  let photoLibrary = PhotoLibrary()

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    // viewDidLoad等ではwindowがnilになるので注意
    let screenSize = view.window!.screen.bounds.size

    setup(screenSize: screenSize)
}

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

  }

  override func textWillChange(_ textInput: UITextInput?) {
    // The app is about to change the document's contents. Perform any preparation here.
  }

  override func textDidChange(_ textInput: UITextInput?) {

  }

  private func setup(screenSize: CGSize) {
    let keyboardView = KeyboardView()

    // keyboardViewのSuperViewのSuperView(UIHostingController)の背景を透明にする
    let hostingController = UIHostingController(
      rootView: keyboardView
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        .environment(\.screenSize, screenSize)
    )

    addChild(hostingController)
    view.addSubview(hostingController.view)
    hostingController.didMove(toParent: self)

    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      hostingController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
      hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
      hostingController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      view.heightAnchor.constraint(equalToConstant: screenSize.width)
    ])
  }

}

struct KeyboardView: View {
  @Environment(\.photoLibrary) var photoLibrary

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Photo.createdDate, ascending: false)],
    animation: .default)
  var photos: FetchedResults<Photo>
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Tag.createdDate, ascending: false)],
    animation: .default)
  var tags: FetchedResults<Tag>

  @State var selectedTags: [Tag] = []
  @State var assets: [Asset] = []

  var body: some View {
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
      .padding(.horizontal, 8)
      .padding(.top, 8)

      ScrollView(.vertical) {
        VGrid(elements: assets, gridCount: 3, spacing: 1) { asset in
          let photo = photos.first(where: { asset.cloudIdentifier == $0.phAssetCloudIdentifier })
          PhotoAssetListImage(
            asset: asset,
            photo: photo,
            tags: tags.toArray()
          )
        }
      }
    }
    .onAppear {
      fetch()
    }
  }

  var filteredAssets: [Asset] {
    if selectedTags.isEmpty {
      return assets
    } else {
      let filteredPhotos: [(photo: Photo, photoTagIDs: [String])] = photos.toArray().compactMap { photo in
        if let tagIDs = photo.tagIDs {
          return (photo: photo, photoTagIDs: tagIDs)
        } else {
          return nil
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

  private func fetch() {
    // iOS keyboard extensionのメモリ制限が77MBらしいので、最新の30件のみを取得してメモリ使用料をセーブする
    assets = PhotoLibraryKey.defaultValue.fetchAssets(fetchLimit: 10).toArray().compactMap { asset in
      return .init(phAsset: asset, cloudIdentifier: nil)
    }
  }
}

struct PhotoAssetListImage: View {
  @Environment(\.screenSize) var screenSize
  @Environment(\.managedObjectContext) private var viewContext

  let asset: Asset
  let photo: Photo?
  let tags: [Tag]

  struct SelectedElement: Hashable {
    let photo: Photo
    let asset: Asset
  }

  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      let width = screenSize.width / 3 - 2
      AsyncAssetImage(asset: asset, maxImageLength: width) { image in
        image
          .resizable()
          .scaledToFill()
          .clipped()
      } placeholder: {
        Image(systemName: "photo")
      }
      .frame(width: width, height: width)

      AssetCopyButton(asset: asset)
        .frame(width: 32, height: 32)
    }
  }
}
