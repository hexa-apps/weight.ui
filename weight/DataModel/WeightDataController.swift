//
//  WeightDataController.swift
//  weight
//
//  Created by berkay on 18.08.2022.
//

import Foundation
import CoreData

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
    
    func add(weight: Float, when time: Date, context: NSManagedObjectContext) {
        let entity = WeightEntity(context: context)
        entity.weight = weight
        entity.time = time
        save(context: context)
    }
    
    
}
