import Foundation
import SwiftUI
import Photos

struct AsyncAssetImage<Content: View>: View {
  @Environment(\.photoLibrary) var photoLibrary
  @State var phase: AssetAsyncImagePhase

  let asset: Asset
  let maxImageLength: CGFloat
  let deliveryMode: PHImageRequestOptionsDeliveryMode
  @ViewBuilder let content: (AssetAsyncImagePhase) -> Content

  init(asset: Asset, maxImageLength: CGFloat, deliveryMode: PHImageRequestOptionsDeliveryMode = .fastFormat, @ViewBuilder content: @escaping (AssetAsyncImagePhase) -> Content) {
    self.asset = asset
    self.maxImageLength = maxImageLength
    self.content = content
    self.deliveryMode = deliveryMode

    phase = .empty
  }

  public init<I: View, P: View>(asset: Asset, maxImageLength: CGFloat, @ViewBuilder content: @escaping (Image) -> I, @ViewBuilder placeholder: @escaping () -> P) where Content == _ConditionalContent<I, P> {
    self.init(asset: asset, maxImageLength: maxImageLength) { phase in
      if let image = phase.image {
        content(image)
      } else {
        placeholder()
      }
    }
  }

  enum AssetAsyncImagePhase {
    /// No image is loaded.
    case empty

    /// An image succesfully loaded.
    case success(Image)

    var image: Image? {
      switch self {
      case let .success(image):
        return image
      case _:
        return nil
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
    guard let image = await photoLibrary.firstImage(asset: asset, maxImageLength: maxImageLength, deliveryMode: deliveryMode) else {
      phase = .empty
      return
    }

    phase = .success(Image(uiImage: image))
  }

}

