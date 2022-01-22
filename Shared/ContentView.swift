import SwiftUI
import CoreData
import Photos
import UniformTypeIdentifiers
import PhotosUI

struct ContentView: View {
  @Environment(\.photoLibrary) private var photoLibrary
  @Environment(\.managedObjectContext) private var viewContext

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Photo.createdDate, ascending: false)],
    animation: .default)
  private var photos: FetchedResults<Photo>
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Tag.createdDate, ascending: false)],
    animation: .default)
  private var tags: FetchedResults<Tag>

  @State var showsPhotoLibraryPicker: Bool = false
  @State var editingPhoto: Photo? = nil
  @State var error: Error?
  @State var searchText: String = ""
  @State var selectedTags: [Tag] = []

  private let gridItems: [GridItem] = [
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
  ]
  private var filteredPhotos: [Photo] {
    photos.filter { photo in
      guard let photoTagIDs = photo.tagIDs else {
        return false
      }

      return photoTagIDs.contains { photoTagID in
        selectedTags.contains { tag in
          tag.id?.uuidString == photoTagID
        }
      }
    }
  }

  var body: some View {
    Group {
      if photos.isEmpty {
        VStack(alignment: .center, spacing: 10) {
          Button(action: {
            showsPhotoLibraryPicker = true
          }, label: {
            Image(systemName: "plus")
              .font(.system(size: 40))
              .padding()
              .foregroundColor(.black)
              .overlay(Circle().stroke(Color.black))
          })

          Text("画像を追加しよう")
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarHidden(true)

      } else {
        ScrollView(.vertical) {
            VStack {
              TagLine(tags: tags.toArray()) { tag in
                TagView(tag: tag, isSelected: selectedTags.contains(tag))
                  .onTapGesture {
                    if selectedTags.contains(tag) {
                      selectedTags.removeAll { $0.id == tag.id }
                    } else {
                      selectedTags.append(tag)
                    }
                  }
              }

              LazyVGrid(columns: gridItems, spacing: 1) {
                ForEach(filteredPhotos) { photo in
                  if let imageData = photo.imageData, let image = UIImage(data: imageData) {
                    GridImage(image: image)
                      .onTapGesture {
                        editingPhoto = photo
                      }
                      .sheet(item: $editingPhoto) { photo in
                        PhotoEditPage(image: image, photo: photo, tags: tags.toArray())
                      }
                  }
                }
              }
            }
          }
          .toolbar {
          ToolbarItem {
            Button(action: {
              showsPhotoLibraryPicker = true
            }) {
              Label("Add Item", systemImage: "plus")
            }
          }
        }
        .navigationTitle("保存済み")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "検索")
      }
    }
    .sheet(isPresented: $showsPhotoLibraryPicker) {
      PhotoLibraryPicker(error: $error) { results in
        assert(results.count == 1)
        guard let result = results.first else {
          return
        }

        addPhoto(with: result)
      }
    }
    .handle(error: $error)
  }

  private func addPhoto(with result: PHPickerResult) {
    result.itemProvider.registeredTypeIdentifiers.forEach { identifier in
      // See also: https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html
      guard let utType = UTType.init(identifier) else {
        assertionFailure()
        return
      }

      if utType.conforms(to: .image) {
        result.itemProvider.loadObject(ofClass: UIImage.self) { itemProviderReading, error in
          switch (itemProviderReading, error) {
          case (nil, let error?):
            self.error = error
          case (let image as UIImage, _):
            let imageData: Data?
            if utType.conforms(to: .png) {
              imageData = image.pngData()
            } else if (utType.conforms(to: .jpeg)) {
              imageData = image.jpegData(compressionQuality: 1.0)
            } else {
              return
            }
            guard let imageData = imageData else {
              return
            }

            do {
              try Photo.createAndSave(context: viewContext, imageData: imageData)
            } catch {
              self.error = error
            }
          case _:
            fatalError()
          }
        }
      }
    }
  }
}

private let itemFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateStyle = .short
  formatter.timeStyle = .medium
  return formatter
}()

struct ContentView_Previews: PreviewProvider {
  static var viewContext: NSManagedObjectContext { PersistenceController.preview.container.viewContext }

  static var previews: some View {
    Group {
      ContentView()
      ContentView()
        .onAppear {
          let photo = Photo(context: viewContext)
          photo.id = .init()
          try! viewContext.save()
        }
    }
  }
}
