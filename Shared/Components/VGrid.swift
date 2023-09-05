import SwiftUI

struct VGrid<E, Content: View>: View {
  let elements: [E]
  let gridCount: Int
  let spacing: CGFloat
  @ViewBuilder let content: (E) -> Content

  var body: some View {
    Grid(alignment: .leading, horizontalSpacing: spacing, verticalSpacing: spacing) {
      let chunkedList = elements.chunked(by: gridCount)
      ForEach(0..<chunkedList.count, id: \.self) { i in
        let chunked = chunkedList[i]
        GridRow(alignment: .top) {
          ForEach(0..<gridCount, id: \.self) { j in
            if chunked.count > j {
              content(chunked[j])
            } else {
              Color.clear.frame(maxWidth: .infinity)
            }
          }
        }
      }
    }
    .frame(maxWidth: .infinity)
  }
}
