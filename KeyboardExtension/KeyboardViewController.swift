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
  @objc func xxCopy(sender: AnyObject) {
    let button = sender as! UIButton
    let tag = button.tag
    let asset = assets[tag]
    Task { @MainActor in
      if let image = await PhotoLibraryKey.defaultValue.highQualityImage(for: asset) {
        Pasteboard.general.image = image
      } else {
        fatalError("image not found")
      }
    }
  }


  var assets: [Asset] = []
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    fetchFirst()
  }

  func setup(assets: [Asset]) {
    let keyboardView = KeyboardView(assets: assets, selector: #selector(xxCopy(sender:)))

    // keyboardViewのSuperViewのSuperView(UIHostingController)の背景を透明にする
    let hostingController = UIHostingController(
      rootView: keyboardView
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        .environment(\.screenSize, view.window!.screen.bounds.size)
    )

    self.addChild(hostingController)
    self.view.addSubview(hostingController.view)
    hostingController.didMove(toParent: self)

    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      hostingController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
      hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
      hostingController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])

  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
  }

  override func textWillChange(_ textInput: UITextInput?) {
    // The app is about to change the document's contents. Perform any preparation here.
  }

  override func textDidChange(_ textInput: UITextInput?) {

  }

  func fetchFirst() {
    let phAssets = PhotoLibraryKey.defaultValue.fetchAssets().toArray()
    let sortedAssets = phAssets.sorted { lhs, rhs in
      if let l = lhs.creationDate?.timeIntervalSinceReferenceDate, let r = rhs.creationDate?.timeIntervalSinceReferenceDate {
        return l > r
      } else {
        assertionFailure()
        return false
      }
    }

    let cloudIdentifiers = PHPhotoLibrary.shared().cloudIdentifierMappings(forLocalIdentifiers: sortedAssets.map(\.localIdentifier))
    assets = sortedAssets.compactMap { asset in
      guard let cloudIdentifier = try? cloudIdentifiers[asset.localIdentifier]?.get().stringValue else {
        return nil
      }
      return .init(phAsset: asset, cloudIdentifier: cloudIdentifier)
    }

    setup(assets: assets)
  }
}

struct KeyboardView: View {
  @Environment(\.photoLibrary) var photoLibrary
  private let helloWorldText = "Hello, world!"

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Photo.createdDate, ascending: false)],
    animation: .default)
  var photos: FetchedResults<Photo>
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Tag.createdDate, ascending: false)],
    animation: .default)
  var tags: FetchedResults<Tag>

  let assets: [Asset]
  let selector: Selector

  var body: some View {
    PhotoAssetListGrid(assets: assets, photos: photos.toArray(), tags: tags.toArray(), selector: selector)
  }

}

struct PhotoAssetListGrid: View {
  @Environment(\.managedObjectContext) private var viewContext

  let assets: [Asset]
  let photos: [Photo]
  let tags: [Tag]
  let selector: Selector

  let sectionHeaderFomatter: DateIntervalFormatter = {
    let formatter = DateIntervalFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
  }()

  var body: some View {
    ScrollView(.vertical) {
      ForEach(assets, id: \.localIdentifier) { asset in
        let photo = photos.first(where: { asset.cloudIdentifier == $0.phAssetCloudIdentifier })

          PhotoAssetListImage(
            asset: asset,
            photo: photo,
            tags: tags,
            selector: selector
          )
          .clipped()
          .aspectRatio(1, contentMode: .fit)
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

struct PhotoAssetListImage: View {
  @Environment(\.screenSize) var screenSize
  @Environment(\.managedObjectContext) private var viewContext

  let asset: Asset
  let photo: Photo?
  let tags: [Tag]
  let selector: Selector

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

  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      AsyncAssetImage(asset: asset, maxImageLength: screenSize.width / 3 - 2) { image in
        image
          .resizable()
          .scaledToFill()
          .clipped()
      } placeholder: {
        Image(systemName: "photo")
      }

      AssetCopyButton(asset: asset)
        .frame(width: 32, height: 32)
    }
    .handle(error: $error)
  }
}
