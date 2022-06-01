//
//  Datafile+CoreDataClass.swift
//
//  Created by deeje cooley on 4/18/22.
//

import CoreData

@objc(Datafile)
public class Datafile: NSManagedObject {
    
    enum Contents: String {
        case unknown
        case image
        case thumbnail
    }
    
    var contents: Contents {
        get {
            return contentsRaw == nil ? .unknown : Contents(rawValue: contentsRaw!)!
        }
        set {
            contentsRaw = newValue.rawValue
            
            switch contents {
            case .unknown:
                suffix = nil
            case .image:
                suffix = ".png"
            case .thumbnail:
                suffix = ".png"
            }
        }
    }
    
}
