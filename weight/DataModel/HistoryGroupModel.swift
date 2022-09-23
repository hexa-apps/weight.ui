//
//  TryModel.swift
//  weight
//
//  Created by berkay on 23.09.2022.
//

import Foundation

struct HistoryGroupModel: Identifiable {
    let id: UUID = UUID()
    let title: String
    let weights: [HistoryModel]
}
