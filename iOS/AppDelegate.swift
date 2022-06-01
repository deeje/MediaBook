//
//  AppDelegate.swift
//
//  Created by deeje cooley on 12/7/21.
//

import UIKit
import CoreData
import CloudKit

import CloudCore
import Connectivity

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer.mediaBook()
        let viewContext = container.viewContext
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.name = "viewContext"
        viewContext.transactionAuthor = "App"
        
        return container
    }()
    
    var connectivity: Connectivity?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        application.registerForRemoteNotifications()
        CloudCore.enable(persistentContainer: persistentContainer)
        
        let connectivityChanged: (Connectivity) -> Void = { connectivity in
            let online : [ConnectivityStatus] = [.connected, .connectedViaCellular, .connectedViaWiFi]
            CloudCore.isOnline = online.contains(connectivity.status)
        }
        
        connectivity = Connectivity(shouldUseHTTPS: false)
        connectivity?.whenConnected = connectivityChanged
        connectivity?.whenDisconnected = connectivityChanged
        connectivity?.startNotifier()

        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Check if it CloudKit's and CloudCore notification
        if CloudCore.isCloudCoreNotification(withUserInfo: userInfo) {
            // Fetch changed data from iCloud
            CloudCore.pull(using: userInfo, to: persistentContainer, error: {
                print("fetchAndSave from didReceiveRemoteNotification error: \($0)")
            }, completion: { fetchResult in
                completionHandler(fetchResult.uiBackgroundFetchResult)
            })
        }
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        CloudCore.pull(to: persistentContainer) {
            print("fetchAndSave from performFetchWithCompletionHandler error: \($0)")
        } completion: { fetchResult in
            completionHandler(fetchResult.uiBackgroundFetchResult)
        }
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "default", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
}

