import Foundation

struct IdentifiableError: LocalizedError, Identifiable {
  let error: Error
  init(_ error: Error) {
    self.error = error
  }

  var id: AnyHashable {
    "\(error._domain)\(error._code)"
  }
  var localizedDescription: String {
    return error.localizedDescription
  }
}
