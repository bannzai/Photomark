import SwiftUI

struct PhotoAssetSelectFloatingActionButton: View {
  var body: some View {
    HStack(spacing: 16) {
      Element(text: Text("Add Tag"), icon: Image(systemName: "bookmark"))
      Element(text: Text("Remove all Tag"), icon: Image(systemName: "bookmark"))
      Element(text: Text("Add To"), icon: Image(systemName: "bookmark"))
    }
    .padding()
  }

  enum Kind {
    case addTag
    case removeAllTag
  }

  struct Element<T: View, I: View>: View {
    let text: T
    let icon: I
    var body: some View {
      VStack(spacing: 8) {
        icon
        text
      }
    }
  }
}
