import SwiftUI
import class UIKit.UIImage

struct PhotoEditPage: View {
  let photo: Photo
  let image: UIImage

  var body: some View {
    VStack(spacing: 10) {
      Image(uiImage: image)
    }
  }
}
