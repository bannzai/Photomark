import Foundation
import CoreData
import SwiftUI

extension FetchedResults {
  func toArray() -> [Result] {
    map { $0 }
  }
}
