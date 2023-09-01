import SwiftUI

struct EntryView: View {
  let persistenceController = PersistenceController.shared

  @State var screenSize = CGSize.zero

  var body: some View {
    NavigationView {
      PhotoAssetListPage()
        .background(alignment: .center) {
          GeometryReader {
            Color.clear.preference(key: ScreenSizePreferenceKey.self, value: $0.size)
          }
          .onPreferenceChange(ScreenSizePreferenceKey.self, perform: { value in
            self.screenSize = value
          })
        }
        .environment(\.screenSize, screenSize)
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
        .onChange(of: screenSize) { newValue in
          print("screenSize:", screenSize)
        }
    }
  }
}

struct ScreenSizeEnvironmentKey: EnvironmentKey {
  static var defaultValue: CGSize = .zero
}

extension EnvironmentValues {
  var screenSize: CGSize {
    get {
      self[ScreenSizeEnvironmentKey.self]
    }
    set {
      self[ScreenSizeEnvironmentKey.self] = newValue
    }
  }
}

struct ScreenSizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
    value = nextValue()
  }
}
