import SwiftUI
import class UIKit.UIImage
import CoreData

struct PhotoEditPage: View {
  @EnvironmentObject var appViewModel: AppViewModel
  @Environment(\.managedObjectContext) private var viewContext

  let image: UIImage
  let photoID: Photo.ID

  @State var tagName: String = ""
  @State var error: Error?

  var photo: Photo {
    appViewModel.photo(id: photoID)!
  }

  var body: some View {
    ScrollView(.vertical) {
      VStack(spacing: 10) {
        TextField("Input tag name and press Enter",text: $tagName)
          .padding(8)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .onSubmit {
            do {
              try Tag.createAndSave(context: viewContext, name: tagName)
            } catch {
              self.error = error
            }

            tagName = ""
          }

        TagLine(tags: appViewModel.tags.toArray()) { tag in
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
    PhotoEditPage(image: UIImage(systemName: "plus")!, photoID: photo.id)
      .environmentObject(AppViewModel())
  }
}
