import SwiftUI


func gridItems() -> [GridItem] {
  #if os(iOS)
  [
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
  ]
  #elseif os(macOS)
  guard let mainScreen = NSScreen.main else {
    return [
      .init(.flexible(), spacing: 1),
      .init(.flexible(), spacing: 1),
      .init(.flexible(), spacing: 1),
    ]
  }
  return (0..<Int(floor(mainScreen.frame.width / 200))).map { _ in
      .init(.flexible(minimum: 200), spacing: 1)
  }
  #endif
}
