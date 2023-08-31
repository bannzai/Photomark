//
//  KeyboardViewController.swift
//  KeyboardExtension
//
//  Created by bannzai on 2023/08/31.
//

import UIKit
import SwiftUI

class KeyboardViewController: UIInputViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    let nextKeyboardAction = #selector(self.handleInputModeList(from:with:))
    // カスタムUIのセットアップをここで行う
    let keyboardView = KeyboardView(needsInputModeSwitchKey: needsInputModeSwitchKey,
                                    nextKeyboardAction: nextKeyboardAction,
                                    inputTextAction: { [weak self] text in
      guard let self else { return }
      self.textDocumentProxy.insertText(text)

    }, deleteTextAction: { [weak self] in
      guard let self,
            self.textDocumentProxy.hasText else { return }

      self.textDocumentProxy.deleteBackward()
    })

    // keyboardViewのSuperViewのSuperView(UIHostingController)の背景を透明にする
    let hostingController = UIHostingController(rootView: keyboardView)

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
}

struct KeyboardView: View {

  let persistenceController = PersistenceController.shared

  let needsInputModeSwitchKey: Bool
  let nextKeyboardAction: Selector
  let inputTextAction: (String) -> Void
  let deleteTextAction: () -> Void

  private let helloWorldText = "Hello, world!"

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Photo.createdDate, ascending: false)],
    animation: .default)
  var photos: FetchedResults<Photo>
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Tag.createdDate, ascending: false)],
    animation: .default)
  var tags: FetchedResults<Tag>

  var body: some View {
    PhotoAssetListGrid(assets: [], photos: photos.toArray(), tags: tags.toArray())
      .environment(\.managedObjectContext, persistenceController.container.viewContext)
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
    let button = UIButton()
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
  let sections: [AssetSection]
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
    List {
      ForEach(0..<sections.count) { i in
        // FIXME: cause out of index when filtering with photo tags
        if i <= sections.count - 1 {
          let section = sections[i]

          LazyVGrid(columns: gridItems(), spacing: 1) {
            Section(header: sectionHeader(section)) {
              ForEach(section.assets) { asset in
                let photo = photos.first(where: { asset.cloudIdentifier == $0.phAssetCloudIdentifier })

                GridAssetImageGeometryReader { gridItemGeometry in
                  PhotoAssetListImage(
                    asset: asset,
                    photo: photo,
                    tags: tags,
                    maxImageLength: gridItemGeometry.size.width
                  )
                }
              }
            }
          }
        }
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

      AssetCopyButton(asset: asset)
        .frame(width: 32, height: 32)
    }
    .frame(width: maxImageLength, height: maxImageLength)
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
    .handle(error: $error)
  }
}
