//
//  HistoryCard.swift
//  weight
//
//  Created by berkay on 29.08.2022.
//

import SwiftUI

struct HistoryCard: View {
    let weight: Double
    let date: String
    let icon: String
    let color: Color
    let unit: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .frame(width: 36, height: 36)
                .foregroundColor(color)
                .padding(.trailing, 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(String(format: "%.2f", weight) + " \(unit)").font(.system(size: 20))
                Text(date).font(.system(size: 16)).fontWeight(.light)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .padding(.trailing, 8)
        }
    }
}
