//
//  weightApp.swift
//  weight
//
//  Created by berkay on 25.07.2022.
//

import SwiftUI

@main
struct weightApp: App {
    @StateObject private var dataController = WeightDataController()
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
