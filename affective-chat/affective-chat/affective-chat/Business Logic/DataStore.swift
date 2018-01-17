//
//  DataStore.swift
//  affective-chat
//
//  Created by vfu on 15.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation
import CoreData

protocol DataStoreProtocol {
    func save() throws
    func insertNewObject<T: NSManagedObject>(forEntityType entityType: T.Type) -> T
    func delete(_ object: NSManagedObject) throws
}

final class CoreDataStack: DataStoreProtocol {

    func save() throws {
        try saveContext()
    }

    func insertNewObject<T: NSManagedObject>(forEntityType entityType: T.Type) -> T {
        return NSEntityDescription.insertNewObject(
            forEntityName: String(describing: entityType),
            into: managedObjectContext) as! T
    }

    func delete(_ object: NSManagedObject) throws {
        managedObjectContext.delete(object)
        try save()
    }

    // MARK: - Private Properties

    private var managedObjectContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    lazy private var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Private Functions

    private func saveContext () throws {
        guard managedObjectContext.hasChanges else {
            return
        }

        managedObjectContext.perform {
            do {
                try self.managedObjectContext.save()
            } catch {
                dlog("An error occured while saving the view context \(error)")
            }
        }
    }

}
