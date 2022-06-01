//
//  OSLog+MediaBook.swift
//
//  Created by deeje cooley on 07/20/21.
//  Copyright © 2021 deeje LLC. All rights reserved.
//

import Foundation
import os.log

extension OSLog {
    
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let model = OSLog(subsystem: subsystem, category: "model")
    static let user = OSLog(subsystem: subsystem, category: "user")
    static let viewController = OSLog(subsystem: subsystem, category: "viewController")
    static let sharing = OSLog(subsystem: subsystem, category: "sharing")
    
}
