import SwiftUI

struct ListHighlightButtonStyle: ButtonStyle {
  let isSelected: Bool

  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .padding()
      .foregroundColor(.white)
      .background(isSelected ? Color.blue : .clear)
      .cornerRadius(8.0)
  }
}

extension View {
  func listHighlightButtonStyle(isSelected: Bool) -> some View {
    buttonStyle(ListHighlightButtonStyle(isSelected: isSelected))
  }
}
