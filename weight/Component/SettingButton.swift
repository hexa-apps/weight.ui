//
//  SettingButton.swift
//  weight
//
//  Created by berkay on 18.08.2022.
//

import SwiftUI

struct SettingButton: View {
    let title: String
    let imageSystemName: String
    let onTapFunction: () -> Void
    
    var body: some View {
        Button {
            onTapFunction()
        } label: {
            HStack {
                Text(title).font(.callout)
                Spacer()
                Image(systemName: imageSystemName)
            }
        }
    }
}
