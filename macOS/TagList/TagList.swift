import SwiftUI

struct TagList: View {
  @Environment(\.managedObjectContext) var viewContext
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Tag.createdDate, ascending: false)],
    animation: .default)
  var tags: FetchedResults<Tag>

  @State var selectedElements: Set<ListElement> = [.all]

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
          PhotoAssetListPage(selectedTags: selectedElements.compactMap(mappedTag))
        },
        label: {
          EmptyView()
        }
      )


      List(allElements, id: \.self, selection: $selectedElements) { tag in
        Button {
          if tag == .all {
            selectedElements = [.all]
          } else {
            if let allIndex = selectedElements.firstIndex(of: .all) {
              selectedElements.remove(at: allIndex)
            }

            if let index = selectedElements.firstIndex(of: tag) {
              selectedElements.remove(at: index)
            } else {
              selectedElements.insert(tag)
            }
          }
        } label: {
          Text(tag.name)
        }
      }
      .buttonStyle(.plain)
    }
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

