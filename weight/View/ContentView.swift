//
//  ContentView.swift
//  weight
//
//  Created by berkay on 25.07.2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView().tabItem {
                Label("", systemImage: "house")
            }
            HistoryView().tabItem {
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
