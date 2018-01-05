//
//  DataController.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 15.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation
import CoreData

class DataController {

    lazy var mainMoc: NSManagedObjectContext = {
        let moc = self.persistentContainer.viewContext
        moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return moc
    }()

    lazy private var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { _, error in
            guard let error = error as NSError? else {
                return
            }

            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You
            // should not use this function in a shipping application, although it may be useful
            // during development.

            /*
             Typical reasons for an error here include:
             * The parent directory does not exist, cannot be created, or disallows writing.
             * The persistent store is not accessible, due to permissions or data protection
             * when the device is locked.
             * The device is out of space.
             * The store could not be migrated to the current model version.
             Check the error message to determine what the actual problem was.
             */
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }

        return container
    }()

    // MARK: - Lifecycle

    static let shared = DataController()
    private init() { }

    // MARK: - Public Functions

    func childMoc() -> NSManagedObjectContext {
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.parent = mainMoc
        moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return moc
    }

}
