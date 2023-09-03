import SwiftUI

struct VGrid<E, Content: View>: View {
  let elements: [E]
  let gridCount: Int
  @ViewBuilder let content: (E) -> Content

  var body: some View {
    Grid {
      let chunkedList = elements.chunked(by: gridCount)
      ForEach(chunkedList.indices, id: \.self) { i in
        GridRow {
          ForEach(chunkedList[i].indices, id: \.self) { j in
            content(chunkedList[i][j])
          }
        }
      }
    }
    .frame(maxWidth: .infinity)
  }
}
