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
                Label("", systemImage: "house").foregroundColor(Color(0xFF3E2AD1))
            }
            HistoryView(weights: weights).tabItem {
                Label("", systemImage: "calendar")
            }
            SettingsView().tabItem {
                Label("", systemImage: "gearshape")
            }
        }
        .accentColor(light: Color(0xFF3E2AD1), dark: Color(0xFF6753F4))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
