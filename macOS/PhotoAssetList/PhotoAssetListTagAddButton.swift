import SwiftUI

struct PhotoAssetListTagAddButton: View {
  @Environment(\.photoLibrary) var photoLibrary

  let asset: Asset
  @StateObject var photo: Photo

  @State var isTagAddPresented = false

  var body: some View {
    Button(action: {
      isTagAddPresented = true
    }) {
      Image(systemName: "plus")
    }
  }
}

