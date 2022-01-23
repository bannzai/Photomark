import Foundation
import SwiftUI
import Photos

struct AssetAsyncImage<Content: View>: View {
  @Environment(\.photoLibrary) var photoLibrary
  @State var phase: AssetAsyncImagePhase

  let asset: Asset
  let maxImageLength: CGFloat
  let content: (AssetAsyncImagePhase) -> Content

  init(asset: Asset, maxImageLength: CGFloat = .infinity, @ViewBuilder content: @escaping (AssetAsyncImagePhase) -> Content) {
    self.asset = asset
    self.maxImageLength = maxImageLength
    self.content = content

    if let image = asset.image {
      phase = .success(Image(uiImage: image))
    } else {
      phase = .empty
    }
  }

  enum AssetAsyncImagePhase {
    /// No image is loaded.
    case empty

    /// An image succesfully loaded.
    case success(Image)

    var image: Image? {
      switch self {
      case .empty:
        return nil
      case let .success(image):
        return image
      }
    }
  }

  public var body: some View {
    content(phase)
      .animation(Transaction().animation, value: phase.image)
      .task(id: asset.id) {
        await load()
      }
  }

  private func load() async {
    guard let image = await photoLibrary.firstImage(asset: asset, maxImageLength: maxImageLength) else {
      phase = .empty
      return
    }

    asset.image = image
    phase = .success(Image(uiImage: image))
  }

}
