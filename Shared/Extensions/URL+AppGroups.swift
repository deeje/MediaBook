//
//  URL+AppGroups.swift
//  MediaBook
//
//  Created by deeje cooley on 3/9/21.
//

import Foundation

public extension URL {
    
    static func container(for appGroup: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }
        
        return fileContainer
    }
    
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        return container(for: appGroup).appendingPathComponent("\(databaseName).sqlite")
    }
    
}
