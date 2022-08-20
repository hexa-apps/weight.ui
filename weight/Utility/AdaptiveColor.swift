//
//  AdaptiveColor.swift
//  findmything.ui
//
//  Created by berkay on 10.08.2022.
//

import Foundation
import SwiftUI

struct AdaptiveForegroundColorModifier: ViewModifier {
    var lightModeColor: Color
    var darkModeColor: Color
    
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content.foregroundColor(resolvedColor)
    }
    
    private var resolvedColor: Color {
        switch colorScheme {
        case .light:
            return lightModeColor
        case .dark:
            return darkModeColor
        @unknown default:
            return lightModeColor
        }
    }
}

struct AdaptiveAccentColorModifier: ViewModifier {
    var lightModeColor: Color
    var darkModeColor: Color
    
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content.accentColor(resolvedColor)
    }
    
    private var resolvedColor: Color {
        switch colorScheme {
        case .light:
            return lightModeColor
        case .dark:
            return darkModeColor
        @unknown default:
            return lightModeColor
        }
    }
}

struct AdaptiveBackgroundModifier: ViewModifier {
    var lightModeColor: Color
    var darkModeColor: Color
    
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content.background(resolvedColor)
    }
    
    private var resolvedColor: Color {
        switch colorScheme {
        case .light:
            return lightModeColor
        case .dark:
            return darkModeColor
        @unknown default:
            return lightModeColor
        }
    }
}

extension View {
    func foregroundColor(
        light lightModeColor: Color,
        dark darkModeColor: Color
    ) -> some View {
        modifier(AdaptiveForegroundColorModifier(
            lightModeColor: lightModeColor,
            darkModeColor: darkModeColor
        ))
    }
    
    func accentColor(
        light lightModeColor: Color,
        dark darkModeColor: Color
    ) -> some View {
        modifier(AdaptiveAccentColorModifier(
            lightModeColor: lightModeColor,
            darkModeColor: darkModeColor
        ))
    }
    
    func background(
        light lightModeColor: Color,
        dark darkModeColor: Color
    ) -> some View {
        modifier(AdaptiveBackgroundModifier(
            lightModeColor: lightModeColor,
            darkModeColor: darkModeColor
        ))
    }
}
