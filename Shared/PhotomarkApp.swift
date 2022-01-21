//
//  PhotomarkApp.swift
//  Shared
//
//  Created by 廣瀬雄大 on 2022/01/21.
//

import SwiftUI

@main
struct PhotomarkApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
