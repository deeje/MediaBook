//
//  LaunchCoordinator.swift
//  MediaBook
//
//  Created by deeje cooley on 02/23/2002.
//  Copyright © 2022 deeje LLC. All rights reserved.
//

import UIKit
import CoreData
import HealthKit
import os.log
import SwiftUI

class LaunchCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    var persistentContainer: NSPersistentContainer

    init(navigationController: UINavigationController, persistentContainer: NSPersistentContainer) {
        self.navigationController = navigationController
        self.persistentContainer = persistentContainer
    }

    func start() {
        let mediaVC = MediaCollectionViewController.instantiate { coder in
            return MediaCollectionViewController(coder: coder, persistentContainer: self.persistentContainer)
        }
        
        var viewControllers: [UIViewController] = [mediaVC]
        
        self.navigationController.setViewControllers(viewControllers, animated: false)
    }
    
}
