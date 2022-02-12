import SwiftUI
import CoreData
import Photos
import UniformTypeIdentifiers
import PhotosUI

struct PhotoAssetListPage: View {
  @Environment(\.photoLibrary) var photoLibrary
  @Environment(\.managedObjectContext) var viewContext

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Photo.createdDate, ascending: false)],
    animation: .default)
  var photos: FetchedResults<Photo>
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Tag.createdDate, ascending: false)],
    animation: .default)
  var tags: FetchedResults<Tag>

  @State var assets: [Asset] = []
  @State var error: Error?
  @State var searchText: String = ""
  @State var selectedTags: [Tag] = []
  @State var alertType: AlertType?
  @State var isSelectingMode = false

  enum AlertType: Identifiable {
    case openSetting
    case noPermission

    var id: Self { self }
  }

  private let gridItems: [GridItem] = [
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
    .init(.flexible(), spacing: 1),
  ]
  var body: some View {
    Group {
      if false {
        EmptyView()
      } else {
        VStack {
          ScrollView(.vertical) {
              List {
                ForEach(0..<100) { i in
                  Text("\(i)")
                }
              }
            .listStyle(.plain)

          }
        }
      }
    }
  }

  private func sectionHeader() -> some View {
    HStack {
      Text("Section")
        .font(.system(size: 16))
        .bold()
      Spacer()
    }
    .padding(.top, 12)
    .padding(.bottom, 8)
  }
}


struct ContentView_Previews: PreviewProvider {
  static var viewContext: NSManagedObjectContext { PersistenceController.preview.container.viewContext }

  static var previews: some View {
    Group {
      PhotoAssetListPage()
      PhotoAssetListPage()
        .onAppear {
          let photo = Photo(context: viewContext)
          photo.id = .init()
          try! viewContext.save()
        }
    }
  }
}
