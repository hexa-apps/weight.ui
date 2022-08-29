//
//  ContentView.swift
//  weight
//
//  Created by berkay on 25.07.2022.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var manageObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.time, order: .forward)]) var weights: FetchedResults<WeightEntity>

    var body: some View {
        TabView {
            HomeView(weights: weights).tabItem {
                Label("", systemImage: "house")
            }
            HistoryView(weights: weights).tabItem {
                Label("", systemImage: "list.dash")
            }
            SettingsView().tabItem {
                Label("", systemImage: "gearshape")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
