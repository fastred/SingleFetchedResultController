//
//  SingleFetchedResultController.swift
//  SingleObjectExample
//
//  Created by Arkadiusz Holko on 05/06/16.
//  Copyright © 2016 Arkadiusz Holko. All rights reserved.
//

import Foundation
import CoreData

public protocol EntityNameProviding {
    static func entityName() -> String
}

public enum ChangeType {
    case FirstFetch
    case Insert
    case Update
    case Delete
}

public class SingleFetchedResultController<T: NSManagedObject where T: EntityNameProviding> {

    public typealias OnChange = ((T, ChangeType) -> Void)

    public let predicate: NSPredicate
    public let managedObjectContext: NSManagedObjectContext
    public let onChange: OnChange
    public private(set) var object: T? = nil

    public init(predicate: NSPredicate, managedObjectContext: NSManagedObjectContext, onChange: OnChange) {
        self.predicate = predicate
        self.managedObjectContext = managedObjectContext
        self.onChange = onChange

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(objectsDidChange(_:)), name: NSManagedObjectContextObjectsDidChangeNotification, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    public func performFetch() throws {
        let fetchRequest = NSFetchRequest(entityName: T.entityName())
        fetchRequest.predicate = predicate

        let results = try managedObjectContext.executeFetchRequest(fetchRequest)
        assert(results.count < 2) // we shouldn't have any duplicates

        if let result = results.first as? T {
            object = result
            onChange(result, .FirstFetch)
        }
    }

    private typealias Filter = (modifiedObjects: Set<NSManagedObject>) -> [NSManagedObject]

    @objc func objectsDidChange(notification: NSNotification) {
        updateCurrentObjectFromNotification(notification, key: NSInsertedObjectsKey)
        updateCurrentObjectFromNotification(notification, key: NSUpdatedObjectsKey)
        updateCurrentObjectFromNotification(notification, key: NSDeletedObjectsKey)
    }

    private func updateCurrentObjectFromNotification(notification: NSNotification, key: String) {
        guard let modifiedObjects = notification.userInfo?[key] as? Set<NSManagedObject> else {
            return
        }
        
        let matchingObjects = (Array(modifiedObjects) as NSArray)
            .filteredArrayUsingPredicate(self.predicate) as? [NSManagedObject] ?? []
        assert(matchingObjects.count < 2)
        
        guard let matchingObject = matchingObjects.first as? T else {
            return
        }

        object = matchingObject
        onChange(matchingObject, keyToChangeType(key))
    }
    
    private func keyToChangeType(key: String) -> ChangeType {
        let map: [String : ChangeType] = [
            NSInsertedObjectsKey : .Insert,
            NSUpdatedObjectsKey : .Update,
            NSDeletedObjectsKey : .Delete,
            ]
        return map[key]!
    }
}
