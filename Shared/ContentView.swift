import SwiftUI
import CoreData
import Photos
import UniformTypeIdentifiers
import PhotosUI

struct ContentView: View {
  @Environment(\.photoLibrary) private var photoLibrary
  @Environment(\.managedObjectContext) private var viewContext

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Photo.createdDate, ascending: true)],
    animation: .default)
  private var photos: FetchedResults<Photo>

  @State var showsPhotoLibraryPicker: Bool = false
  @State var error: Error?

  private let gridItems: [GridItem] = [
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
  ]

  var body: some View {
    GeometryReader { viewGeometry in
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
          LazyVGrid(columns: gridItems, spacing: 1) {
            ForEach(photos) { photo in
              if let imageData = photo.imageData, let image = UIImage(data: imageData) {
                GridImage(image: image)
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
        .navigationBarTitle("保存済み")
        .navigationBarTitleDisplayMode(.inline)

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
  static var previews: some View {
    ContentView()
  }
}
