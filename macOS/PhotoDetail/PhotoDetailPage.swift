import SwiftUI
import CoreData

struct PhotoDetailPage: View {
  @Environment(\.managedObjectContext) private var viewContext
  @Environment(\.photoLibrary) var photoLibrary

  let asset: Asset
  @StateObject var photo: Photo
  let tags: [Tag]

  @State var tagName: String = ""
  @State var error: Error?
  @State var image: UIImage?
  @State var activitySheetIsPresented = false

  var body: some View {
    if let image = image {
      ScrollView(.vertical) {
        VStack(spacing: 10) {
          TextField("Input tag name and press Enter", text: $tagName)
            .padding(8)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .onSubmit {
              if tags.contains(where: { $0.name == tagName }) {
                error = AlertError("既に存在しています", "他のタグ名を入力してください")
              } else {
                do {
                  if let tag = try Tag.createAndSave(context: viewContext, name: tagName), let tagID = tag.id {
                    photo.tagIDs?.append(tagID.uuidString)
                    tagName = ""
                  }
                } catch {
                  self.error = error
                }
              }
            }

          TagLine(tags: tags.filtered(tagName: tagName)) { tag in
            TagView(tag: tag, isSelected: photo.hasTag(tag))
              .onTapGesture {
                if photo.hasTag(tag) {
                  photo.tagIDs?.removeAll(where: { $0 == tag.id!.uuidString })
                } else {
                  photo.tagIDs?.append(tag.id!.uuidString)
                }

                do {
                  try viewContext.save()
                } catch {
                  self.error = error
                }
              }
          }

          if let image = image {
            Image(uiImage: image)
              .resizable()
              .aspectRatio(contentMode: .fill)
          }
        }
      }
      .toolbar {
        ToolbarItem(placement: .navigation) {
          Button(action: { activitySheetIsPresented = true }) {
            Image(systemName: "square.and.arrow.up")
          }
        }
        ToolbarItem(placement: .navigation) {
          AssetDownloadButton(asset: asset)
        }
        ToolbarItem(placement: .navigation) {
          AssetCopyButton(asset: asset)
        }
      }
      .sheet(isPresented: $activitySheetIsPresented, content: {
        ActivityView(images: [image])
      })
      .handle(error: $error)
    } else {
      ProgressView()
        .task {
          if let image = await photoLibrary.highQualityImage(for: asset) {
              self.image = image
          }
        }
    }
  }
}
