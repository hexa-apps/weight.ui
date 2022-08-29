//
//  WeightDataController.swift
//  weight
//
//  Created by berkay on 18.08.2022.
//

import Foundation
import CoreData
import SwiftUI

class WeightDataController: ObservableObject {
    let container = NSPersistentContainer(name: "WeightDataModel")

    init() {
        container.loadPersistentStores { desc, error in
            if let error = error {
                print("failed \(error)")
            }
        }
    }
    
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
            print("data saved")
        } catch {
            print("error")
        }
    }
    
    func startAddingWeightProcess(weight: Double, when time: Date, weights: FetchedResults<WeightEntity>?, context: NSManagedObjectContext) {
        if let weights = weights {
            if let weightEntity = check(date: time, weights: weights) {
                update(weightEntity: weightEntity, weight: weight, context: context)
            } else {
                add(weight: weight, when: time, context: context)
            }
        } else {
            add(weight: weight, when: time, context: context)
        }
    }
    
    func add(weight: Double, when time: Date, context: NSManagedObjectContext) {
        let entity = WeightEntity(context: context)
        entity.id = UUID()
        entity.weight = weight
        entity.time = time
        save(context: context)
    }
    
    private func update(weightEntity: WeightEntity, weight: Double, context: NSManagedObjectContext) {
        context.performAndWait {
            weightEntity.weight = weight
            try? context.save()
        }
    }
    
    private func check(date: Date, weights: FetchedResults<WeightEntity>) -> WeightEntity? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let dateString = dateFormatter.string(from: date)
        for entity in weights {
            guard let time = entity.time else { return nil }
            let entityTimeString = dateFormatter.string(from: time)
            if entityTimeString == dateString {
                return entity
            }
        }
        return nil
    }
    
    
}
