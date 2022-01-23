import SwiftUI
import class UIKit.UIImage
import CoreData

struct PhotoEditPage: View {
  @Environment(\.managedObjectContext) private var viewContext

  let image: UIImage
  @StateObject var photo: Photo
  let tags: [Tag]

  @State var tagName: String = ""
  @State var error: Error?

  var body: some View {
    ScrollView(.vertical) {
      VStack(spacing: 10) {
        TextField("Input tag name and press Enter",text: $tagName)
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

        TagLine(tags: tags) { tag in
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

        Image(uiImage: image)
          .resizable()
          .aspectRatio(contentMode: .fill)
      }
    }
    .handle(error: $error)
  }
}

struct PhotoEditPage_Previews: PreviewProvider {
  static var viewContext: NSManagedObjectContext { PersistenceController.preview.container.viewContext }
  static let photo: Photo = {
    let photo = Photo(context: viewContext)
    photo.id = .init()
    return photo
  }()
  static let tags: [Tag] = ["A", "B", "C", "D", "E", "F", "G"].map {
    let tag = Tag(context: viewContext)
    tag.id = .init()
    tag.name = $0
    return tag
  }

  static var previews: some View {
    PhotoEditPage(image: UIImage(systemName: "plus")!, photo: photo, tags: tags)
  }
}
