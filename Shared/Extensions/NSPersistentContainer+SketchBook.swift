//
//  NSPersistentContainer+MediaBook.swift
//  MediaBook
//
//  Created by deeje cooley on 3/9/21.
//

import CoreData
import CloudCore
import os.log

struct MediaBook {
    
    static let appGroup = "group.com.deeje.MediaBook"
    static let database = "MediaBook"
}

extension NSPersistentContainer {
        
    static func mediaBook() -> NSPersistentContainer {
        let appGroupURL = URL.storeURL(for: MediaBook.appGroup, databaseName: MediaBook.database)
        
        let container = NSPersistentContainer(name: MediaBook.database)
        let storeDescription = NSPersistentStoreDescription(url: appGroupURL)
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                os_log("loadPersistentStores failed: %@, info: %@", log: OSLog.model, type: .error, error.localizedDescription, error.userInfo)
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        return container
    }
    
}
