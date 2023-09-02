import Foundation

extension Array {
  func chunked(by chunkSize: Int) -> [[Element]] {
    return stride(from: 0, to: count, by: chunkSize).map {
      Array(self[$0..<Swift.min($0 + chunkSize, count)])
    }
  }
}

