//
//  NSManagedObject+EntityName.swift
//
//  Created by deeje cooley on 11/17/18.
//  Copyright © 2018 deeje LLC.  All rights reserved.
//

import CoreData

public protocol EntityNameProviding {
    
    static func entityName() -> String
    
}

extension NSManagedObject: EntityNameProviding {
    
    public static func entityName() -> String {
        return entity().name!
    }
    
}
