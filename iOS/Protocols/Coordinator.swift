//
//  Coordinator.swift
//  MediaBook
//
//  Created by deeje cooley on 02/23/2002.
//  Copyright © 2022 deeje LLC. All rights reserved.
//

import UIKit

protocol Coordinator: AnyObject {
    
    var navigationController: UINavigationController { get set }
    
    func start()
    
}
