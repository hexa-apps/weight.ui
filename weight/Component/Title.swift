//
//  Title.swift
//  weight
//
//  Created by berkay on 12.10.2022.
//

import SwiftUI

struct TitleComponent: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.leading, 24)
                .padding(.top, 12)
            Spacer()
        }
    }
}
