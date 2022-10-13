//
//  HomeView.swift
//  weight
//
//  Created by berkay on 25.07.2022.
//

import SwiftUI
import SwiftUICharts
import HalfASheet

struct HomeView: View {
    @AppStorage("dateFilter") private var dateFilter: Int = 0

    @AppStorage("isOnboardingView") private var onboardingViewShow = true

    var body: some View {
        VStack {
            TitleComponent(title: "Summary")
            HomeListView()
        }.background(light: .systemsBackground, dark: .black)
            .fullScreenCover(isPresented: $onboardingViewShow) {
            OnboardingView(onboardingShow: $onboardingViewShow)
        }
//        }
    }
}
