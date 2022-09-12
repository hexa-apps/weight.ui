//
//  OnboardingCard.swift
//  weight
//
//  Created by berkay on 12.09.2022.
//

import SwiftUI

struct OnboardingCard: View {
    let leftColor: Color
    let rightColor: Color
    let midSystemName: String
    
    
    var body: some View {
        HStack {
            Image(systemName: "chevron.left")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(leftColor)
                .padding(.leading, 16)
            Spacer()
            Image(systemName: midSystemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50, alignment: .center)
                .foregroundColor(.white)
                .padding(24)
                .background(Color(0xFF3E2AD1))
                .clipShape(Circle())
                .padding()
            Spacer()
            Image(systemName: "chevron.right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(rightColor)
                .padding(.trailing, 16)
        }
    }
}
