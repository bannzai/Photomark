import SwiftUI

struct ApplyTagPage: View {
  @Environment(\.dismiss) var dismiss
  @Environment(\.managedObjectContext) var viewContext

  let targetAssets: [Asset]
  let onComplete: () -> Void

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Photo.createdDate, ascending: false)],
    animation: .default)
  var photos: FetchedResults<Photo>
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Tag.createdDate, ascending: false)],
    animation: .default)
  var tags: FetchedResults<Tag>
  @State var selectedTags: [Tag] = []
  @State var error: Error?

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
    .toolbar {
      ToolbarItem(placement: .navigation) {
        Button(action: {
          do {
            try targetAssets.forEach { asset in
              let photo: Photo
              if let _photo = photos.first(where: { $0.phAssetIdentifier == asset.id }) {
                photo = _photo
              } else {
                photo = try .createAndSave(context: viewContext, asset: asset)
              }

              if let photoTagIDs = photo.tagIDs {
                selectedTags.forEach { selectedTag in
                  guard let selectedTagID = selectedTag.id?.uuidString else {
                    return
                  }
                  if !photoTagIDs.contains(selectedTagID) {
                    photo.tagIDs?.append(selectedTagID)
                  }
                }
              }
            }

            try viewContext.save()
            dismiss()
            onComplete()
          } catch {
            self.error = error
          }
        }) {
          Text("Done")
        }
      }
    }
    .handle(error: $error)
  }
}

