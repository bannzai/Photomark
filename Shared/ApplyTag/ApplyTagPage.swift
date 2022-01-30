import SwiftUI

struct ApplyTagPage: View {
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Tag.createdDate, ascending: false)],
    animation: .default)
  var tags: FetchedResults<Tag>

  @State var selectedTags: [Tag] = []

  private let columns: [GridItem] = [
    .init(.flexible(minimum: 40)),
    .init(.flexible(minimum: 40)),
    .init(.flexible(minimum: 40)),
    .init(.flexible(minimum: 40)),
  ]

  var body: some View {
    ScrollView(.vertical) {
      LazyVGrid(columns: columns, spacing: 20) {
        ForEach(tags) { tag in
          TagView(tag: tag, isSelected: selectedTags.contains(tag))
            .onTapGesture {
              if selectedTags.contains(tag) {
                selectedTags.removeAll { $0.id == tag.id }
              } else {
                selectedTags.append(tag)
              }
            }
        }
      }
    }
    .frame(maxWidth: .infinity)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: {
          print("TODO")
        }) {
          Text("Done")
        }
      }
    }
  }
}

