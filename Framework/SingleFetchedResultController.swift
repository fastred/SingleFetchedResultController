//
//  SingleFetchedResultController.swift
//  SingleFetchedResultController
//
//  Created by Arkadiusz Holko on 07/06/16.
//  Copyright © 2016 Arkadiusz Holko. All rights reserved.
//

import Foundation
import CoreData

public protocol EntityNameProviding {
    static func entityName() -> String
}

public enum ChangeType {
    case firstFetch
    case insert
    case update
    case delete
}

open class SingleFetchedResultController<T: NSManagedObject> where T: EntityNameProviding {

    public typealias OnChange = ((T, ChangeType) -> Void)

    open let predicate: NSPredicate
    open let managedObjectContext: NSManagedObjectContext
    open let onChange: OnChange
    open fileprivate(set) var object: T? = nil

    public init(predicate: NSPredicate, managedObjectContext: NSManagedObjectContext, onChange: @escaping OnChange) {
        self.predicate = predicate
        self.managedObjectContext = managedObjectContext
        self.onChange = onChange

        NotificationCenter.default.addObserver(self, selector: #selector(objectsDidChange(_:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    open func performFetch() throws {
        let fetchRequest = NSFetchRequest<T>(entityName: T.entityName())
        fetchRequest.predicate = predicate

        let results = try managedObjectContext.fetch(fetchRequest)
        assert(results.count < 2) // we shouldn't have any duplicates

        if let result = results.first {
            object = result
            onChange(result, .firstFetch)
        }
    }

    @objc func objectsDidChange(_ notification: Notification) {
        updateCurrentObject(notification: notification, key: NSInsertedObjectsKey)
        updateCurrentObject(notification: notification, key: NSUpdatedObjectsKey)
        updateCurrentObject(notification: notification, key: NSDeletedObjectsKey)
    }

    fileprivate func updateCurrentObject(notification: Notification, key: String) {
        guard let allModifiedObjects = (notification as NSNotification).userInfo?[key] as? Set<NSManagedObject> else {
            return
        }

        let objectsWithCorrectType = Set(allModifiedObjects.filter { return $0 as? T != nil })
        let matchingObjects = NSSet(set: objectsWithCorrectType)
            .filtered(using: self.predicate) as? Set<NSManagedObject> ?? []

        assert(matchingObjects.count < 2)

        guard let matchingObject = matchingObjects.first as? T else {
            return
        }

        object = matchingObject
        onChange(matchingObject, changeType(fromKey: key))
    }
    
    fileprivate func changeType(fromKey key: String) -> ChangeType {
        let map: [String : ChangeType] = [
            NSInsertedObjectsKey : .insert,
            NSUpdatedObjectsKey : .update,
            NSDeletedObjectsKey : .delete,
            ]
        return map[key]!
    }
}
