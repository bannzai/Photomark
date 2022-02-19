import SwiftUI

struct TagList: View {
  @Environment(\.managedObjectContext) var viewContext
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Tag.createdDate, ascending: false)],
    animation: .default)
  var tags: FetchedResults<Tag>

  @State var selectedElement: ListElement = .all

  enum ListElement: Identifiable, Hashable {
    case all
    case tag(Tag)

    static let allUUID = UUID()

    var name: String {
      switch self {
      case .all:
          return "すべての写真"
      case let .tag(tag):
        return tag.name!
      }
    }

    var id: UUID {
      switch self {
      case .all:
        return ListElement.allUUID
      case let .tag(tag):
        return tag.id!
      }
    }
  }

  var body: some View {
    ZStack {
      NavigationLink(
        isActive: .constant(true), destination: {
          PhotoAssetListPage(selectedTags: [mappedTag(selectedElement)].compactMap { $0 })
            .environment(\.managedObjectContext, viewContext)
        },
        label: {
          EmptyView()
        }
      )


      List(allElements, id: \.self) { tag in
        Button {
          if tag == .all {
            selectedElement = .all
          } else {
            if selectedElement == .all {
              selectedElement = .all
            }

            if selectedElement == tag {
              selectedElement = .all
            } else {
              selectedElement = tag
            }
          }
        } label: {
          Text(tag.name)
        }
        .tag(tag.id)
        .listHighlightButtonStyle(isSelected: selectedElement == tag)
      }
    }
    .padding(.top, 20)
  }

  private var allElements: [ListElement] {
    [.all] + tags.map { .tag($0) }
  }

  private func mappedTag(_ listElement: ListElement) -> Tag? {
    if case let .tag(tag) = listElement {
      return tag
    }
    return nil
  }
}

