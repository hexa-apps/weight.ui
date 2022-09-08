//
//  SplashView.swift
//  weight
//
//  Created by berkay on 8.09.2022.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                Color(0xFF6753F4).edgesIgnoringSafeArea(.all)
                VStack {
                    VStack {
                        Image("splashicon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 64, height: 64, alignment: .center)
                            .cornerRadius(16)
                        Text("Weight Tracker")
                            .font(.system(size: 26))
                            .foregroundColor(Color.white.opacity(0.8))
                    }
                        .scaleEffect(size)
                        .opacity(opacity)
                        .onAppear {
                            withAnimation(.easeIn(duration: 1.2)) {
                                self.size = 0.9
                                self.opacity = 1.0
                            }
                        }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
            
        }
    }
}
