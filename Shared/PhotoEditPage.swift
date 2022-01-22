import SwiftUI
import class UIKit.UIImage
import CoreData

struct PhotoEditPage: View {
  let image: UIImage
  let photo: Photo
  let tags: [Tag]

  @State var tagName: String = ""

  var body: some View {
    ScrollView(.vertical) {
      VStack(spacing: 10) {
        TextField("Input tag name and press Enter",text: $tagName)
          .padding(8)
          .textFieldStyle(RoundedBorderTextFieldStyle())

        TagLine(tags: tags, onTap: { _ in })

        Image(uiImage: image)
          .frame(maxWidth: .infinity)
      }
    }
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
