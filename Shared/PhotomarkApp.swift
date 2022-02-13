import SwiftUI
import Combine

final class Object: ObservableObject {
  @Published var count = 0
}

@main
struct PhotomarkApp: App {

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(Object())
    }
  }
}

struct ContentView: View {
  @EnvironmentObject var object: Object
  var body: some View {
    let _ = Self._printChanges()
    VStack {
      Text("\(object.count)")
      ContentView2()
    }
  }
}

struct ContentView2: View {
  var body: some View {
    let _ = Self._printChanges()
    ContentView3()
  }
}

struct ContentView3: View {
  @EnvironmentObject var object: Object
  var body: some View {
    let _ = Self._printChanges()
    Button {
      object.count += 1
    } label: {
      Text("Test")
    }
  }
}
