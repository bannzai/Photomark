import Foundation
import SwiftUI

struct ErrorHandleModifier: ViewModifier {
  @Binding var error: Error?

  func body(content: Content) -> some View {
    content
    // Avoid SwiftUI Bug's for alert is not shown.
      .background(EmptyView().alert(item: .init(get: {
        error.map(IdentifiableError.init)
      }, set: { identifiableError in
        error = identifiableError?.error
      }), content: { identifiableError in
        if let alertError = identifiableError.error as? AlertError {
          return Alert(
            title: Text(alertError.title),
            message: Text(alertError.message),
            dismissButton: .default(Text("OK"))
          )
        } else {
          return Alert(
            title: Text("予期せぬエラーが発生しました"),
            message: Text(identifiableError.localizedDescription),
            dismissButton: .default(Text("OK"))
          )
        }
      }))
  }
}

extension View {
  func handle(error: Binding<Error?>) -> some View {
    modifier(ErrorHandleModifier(error: error))
  }
}
