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
    static var standart = WeightDataController()
    let container: NSPersistentContainer
    
    private var oldStoreURL: URL {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
        return appSupport.appendingPathComponent("WeightDataModel.sqlite")
    }
    
    private var sharedStoreURL: URL {
        let id = "group.hexaapps.weight.coreData"
        let groupContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: id)!
        return groupContainer.appendingPathComponent("WeightDataModel.sqlite")
    }
    
    init() {
        container = NSPersistentContainer(name: "WeightDataModel")
        
        if !FileManager.default.fileExists(atPath: oldStoreURL.path) {
            container.persistentStoreDescriptions.first!.url = sharedStoreURL
        }
        
        container.loadPersistentStores { desc, error in
            if let error = error {
                print("failed \(error)")
            }
        }
        
        migrateStore(for: container)
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func migrateStore(for migrateContainer: NSPersistentContainer) {
        guard !FileManager.default.fileExists(atPath: sharedStoreURL.path) else { return }
        let coordinator = migrateContainer.persistentStoreCoordinator
        
        guard let oldStore = coordinator.persistentStore(for: oldStoreURL) else { return }
        
        do {
            try coordinator.migratePersistentStore(oldStore, to: sharedStoreURL, options: nil, withType: NSSQLiteStoreType)
        } catch {
            fatalError("Something went wrong while migrating the store: \(error)")
        }
        
        do {
            try FileManager.default.removeItem(at: oldStoreURL)
        } catch {
            fatalError("Something went wrong while deleting the old store: \(error)")
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
