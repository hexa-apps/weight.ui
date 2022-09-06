//
//  HistoryCard.swift
//  weight
//
//  Created by berkay on 29.08.2022.
//

import SwiftUI

struct HistoryCard: View {
    let weight: HistoryModel
    let unit: String

    var body: some View {
        HStack {
            Image(systemName: weight.icon)
                .resizable()
                .frame(width: 36, height: 36)
                .foregroundColor(light: weight.lightColor, dark: weight.darkColor)
                .padding(.trailing, 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(String(format: "%.1f", weight.weight) + " \(unit)").font(.system(size: 20))
                Text(weight.date).font(.system(size: 16, weight: .light).italic())
            }
            Spacer()
            Image(systemName: "chevron.right")
                .padding(.trailing, 8)
        }
    }
}
