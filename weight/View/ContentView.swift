//
//  ContentView.swift
//  weight
//
//  Created by berkay on 25.07.2022.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var manageObjectContext
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("dateFilter") private var dateFilter: Int = 0
    
    @State private var selectedTab: Int = 0
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                HistoryView()
                    .tag(1)
                SettingsView()
                    .tag(2)
            }
            
            // Custom Glass Tab Bar & Add Button
            HStack(spacing: 16) {
                HStack(spacing: 0) {
                    TabBarButton(icon: "house", activeIcon: "house.fill", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    TabBarButton(icon: "calendar", activeIcon: "calendar", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    TabBarButton(icon: "gearshape", activeIcon: "gearshape.fill", isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(
                    Group {
                        if #available(iOS 26.0, *) {
                            VisualEffectBlur(blurStyle: .systemThinMaterial)
                        } else {
                            Capsule().fill(colorScheme == .dark ? Color(white: 0.15) : Color.white)
                        }
                    }
                )
                .overlay(
                    Capsule()
                        .stroke(colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.08), lineWidth: 1)
                )
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.5 : 0.12), radius: 15, x: 0, y: 8)
                
                Button(action: {
                    if selectedTab == 1 {
                        NotificationCenter.default.post(name: Notification.Name("ShowHistoryAddSheet"), object: nil)
                    } else {
                        NotificationCenter.default.post(name: Notification.Name("ShowHomeAddSheet"), object: nil)
                    }
                }) {
                    let isIOS26: Bool = {
                        if #available(iOS 26.0, *) { return true }
                        return false
                    }()
                    
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isIOS26 ? (colorScheme == .dark ? .white : .black) : .white)
                        .frame(width: 48, height: 48)
                        .padding(8)
                        .background(
                            Group {
                                if #available(iOS 26.0, *) {
                                    VisualEffectBlur(blurStyle: .systemThinMaterial)
                                } else {
                                    Circle().fill(colorScheme == .dark ? Color(0xFF6753F4) : Color(0xFF3E2AD1))
                                }
                            }
                        )
                        .overlay(
                            Circle()
                                .stroke(colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.08), lineWidth: 1)
                        )
                        .clipShape(Circle())
                        .shadow(color: isIOS26 ? Color.black.opacity(colorScheme == .dark ? 0.5 : 0.12) : Color(0xFF3E2AD1).opacity(0.4), radius: 15, x: 0, y: 8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

struct TabBarButton: View {
    @Environment(\.colorScheme) var colorScheme
    var icon: String
    var activeIcon: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isSelected {
                    Capsule()
                        .fill(Color.primary.opacity(0.1))
                        .frame(height: 48)
                }
                
                Image(systemName: isSelected ? activeIcon : icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(isSelected ? .primary : .primary.opacity(0.5))
            }
            .frame(height: 48)
            .frame(maxWidth: .infinity)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
