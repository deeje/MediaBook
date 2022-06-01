//
//  Datafile+CloudCoreCacheable.swift
//
//  Created by deeje cooley on 4/18/22.
//

import CoreData
import CloudKit
import CloudCore

extension Datafile: CloudCoreCacheable {
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        
        recordName = UUID().uuidString      // want this precomputed so that url is functional
    }
    
    override public func prepareForDeletion() {
        removeLocal()
    }
    
}
