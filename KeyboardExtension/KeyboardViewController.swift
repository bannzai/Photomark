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

    fetchFirst()
  }

  func setup(assets: [Asset]) {
    let keyboardView = KeyboardView(assets: assets, selector: #selector(xxCopy(sender:)))

    // keyboardViewのSuperViewのSuperView(UIHostingController)の背景を透明にする
    let hostingController = UIHostingController(
      rootView: keyboardView
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
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

struct NextKeyboardButton: View {
  let systemName: String
  let action: Selector

  var body: some View {
    Image(systemName: systemName)
      .overlay {
        NextKeyboardButtonOverlay(action: action)
      }
  }
}

struct NextKeyboardButtonOverlay: UIViewRepresentable {
  let action: Selector

  func makeUIView(context: Context) -> UIButton {
    // UIButtonを生成し、セレクターをactionに設定
    let button = UIButton(type: .custom)
    button.frame = .init(origin: .zero, size: .init(width: 100, height: 100))
    button.addTarget(nil,
                     action: action,
                     for: .allTouchEvents)
    return button
  }

  func updateUIView(_ button: UIButton, context: Context) {}
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
      ForEach(assets) { asset in
        let photo = photos.first(where: { asset.cloudIdentifier == $0.phAssetCloudIdentifier })

          PhotoAssetListImage(
            asset: asset,
            photo: photo,
            tags: tags,
            maxImageLength: 100,
            selector: selector
          )
          .clipped()
          .aspectRatio(1, contentMode: .fit)
      }
      .listRowInsets(.init())
      .listRowSeparator(.hidden)
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

struct PhotoAssetListImage: View {
  @Environment(\.managedObjectContext) private var viewContext

  let asset: Asset
  let photo: Photo?
  let tags: [Tag]
  let maxImageLength: CGFloat
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
      AsyncAssetImage(asset: asset, maxImageLength: maxImageLength) { image in
        image
          .resizable()
          .scaledToFill()
          .frame(width: maxImageLength, height: maxImageLength)
          .clipped()
      } placeholder: {
        Image(systemName: "photo")
      }

      NextKeyboardButton(systemName: "doc.on.doc", action: selector)
        .frame(width: 100, height: 100)
    }
    .frame(width: maxImageLength, height: maxImageLength)
    .handle(error: $error)
  }
}
