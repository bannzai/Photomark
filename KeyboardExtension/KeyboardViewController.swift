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

  let needsInputModeSwitchKey: Bool
  let nextKeyboardAction: Selector
  let inputTextAction: (String) -> Void
  let deleteTextAction: () -> Void

  private let helloWorldText = "Hello, world!"
  let persistenceController = PersistenceController.shared

  var body: some View {
    PhotoAssetListPage()
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
