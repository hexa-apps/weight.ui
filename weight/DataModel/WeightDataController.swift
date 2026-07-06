//
//  WeightDataController.swift
//  weight
//
//  Created by berkay on 18.08.2022.
//

import Foundation
import CoreData
import SwiftUI
import WidgetKit

class WeightDataController: ObservableObject {
    static let standard = WeightDataController()
    let container: NSPersistentContainer
    
    static let appGroupID = "group.hexaapps.weight.coreData"
    
    static var sharedStoreURL: URL {
        let groupContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)!
        return groupContainer.appendingPathComponent("WeightDataModel.sqlite")
    }
    
    /// Shared UserDefaults accessible from both app and widget
    static var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }
    
    init() {
        container = NSPersistentContainer(name: "WeightDataModel")
        
        // Migrate old store to shared App Group location if needed
        let oldStoreURL = NSPersistentContainer.defaultDirectoryURL()
            .appendingPathComponent("WeightDataModel.sqlite")
        let sharedURL = WeightDataController.sharedStoreURL
        
        if FileManager.default.fileExists(atPath: oldStoreURL.path) &&
            !FileManager.default.fileExists(atPath: sharedURL.path) {
            let coordinator = NSPersistentStoreCoordinator(
                managedObjectModel: container.managedObjectModel
            )
            do {
                let oldStore = try coordinator.addPersistentStore(type: .sqlite, at: oldStoreURL)
                try coordinator.migratePersistentStore(oldStore, to: sharedURL, type: .sqlite)
                print("Core Data migrated to shared store")
            } catch {
                print("Migration failed: \(error)")
            }
        }
        
        // Use shared App Group store so widget can access data
        let storeDescription = NSPersistentStoreDescription(url: sharedURL)
        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores { desc, error in
            if let error = error {
                print("failed \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
            print("data saved")
            WidgetCenter.shared.reloadAllTimelines()
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
