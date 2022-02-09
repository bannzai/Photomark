import Foundation

struct AlertError: Error {
  var title: String
  var message: String

  init(_ title: String, _ message: String) {
    self.title = title
    self.message = message
  }
}
