import Foundation
import SwiftUI

extension Photo {
  func hasTag(_ tag: Tag) -> Bool {
    guard let tagIDs = tagIDs else {
      return false
    }
    return tagIDs.contains { $0 == tag.id?.uuidString }
  }
}

extension [Photo] {
  var localIdentifiers: [String] {
    compactMap(\.phAssetLocalIdentifier)
  }
}
