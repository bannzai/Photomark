import SwiftUI

struct VGrid<E, Content: View>: View {
  let elements: [E]
  let gridCount: Int
  let spacing: CGFloat
  @ViewBuilder let content: (E) -> Content

  var body: some View {
    Grid {
      let chunkedList = elements.chunked(by: gridCount)
      ForEach(0..<chunkedList.count, id: \.self) { i in
        let chunked = chunkedList[i]

        GridRow {
          ForEach(0..<chunked.count, id: \.self) { j in
            content(chunked[j])

            if chunked.count - 1 != j {
              Spacer()
                .frame(width: spacing)
            }
          }
        }
      }
    }
    .frame(maxWidth: .infinity)
  }
}
