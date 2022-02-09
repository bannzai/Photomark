import Foundation


extension Array where Element == Tag {
  func filtered(tagName: String) -> [Tag] {
    if tagName.isEmpty {
      return self
    }

    let filtered = filter { tag in
      if let name = tag.name {
        return name.lowercased().contains(tagName.lowercased()) || tagName.lowercased().contains(name.lowercased())
      } else {
        return false
      }
    }

    if filtered.isEmpty {
      return self
    } else {
      return filtered
    }
  }
}
