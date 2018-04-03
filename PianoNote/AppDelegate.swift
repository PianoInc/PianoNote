//
//  AppDelegate.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import CloudKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func performMigration() {
        let url = Realm.Configuration.defaultConfiguration.fileURL
        let config = Realm.Configuration(
            fileURL: url,
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 26,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
                
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        let _ = try! Realm()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("oh yeah!!")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    //This only happens whenever the change has occured from other environment!!
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("got noti!")
        guard let dict = userInfo as? [String: NSObject],
            application.applicationState != .inactive else {return}
        let notification = CKNotification(fromRemoteNotificationDictionary: dict)
        
        guard let subscriptionID = notification.subscriptionID else {return}
        
        
        if subscriptionID.hasPrefix(CloudManager.shared.privateDatabase.subscriptionID) {
            CloudManager.shared.privateDatabase.handleNotification()
            completionHandler(.newData)
        } else if subscriptionID == CloudManager.shared.sharedDatabase.subscriptionID {
            CloudManager.shared.sharedDatabase.handleNotification()
            completionHandler(.newData)
        } else {
            completionHandler(.noData)
        }
        
    }
    
    func application(_ application: UIApplication, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShareMetadata) {
        let acceptShareOperation: CKAcceptSharesOperation =
            CKAcceptSharesOperation(shareMetadatas:
                [cloudKitShareMetadata])
        
        acceptShareOperation.qualityOfService = .userInteractive
        acceptShareOperation.perShareCompletionBlock = {meta, share,
            error in
            print("share was accepted")
        }
        acceptShareOperation.acceptSharesCompletionBlock = {
            error in
            /// Send your user to where they need to go in your app
        }
        CKContainer(identifier:
            cloudKitShareMetadata.containerIdentifier).add(acceptShareOperation)
    }
}

extension Realm {
    static func setDefaultRealmForUser(username: String) {
        
        let defaultConfig = Realm.Configuration.defaultConfiguration
        var config = Realm.Configuration()
        
        // Use the default directory, but replace the filename with the username
        config.fileURL = config.fileURL!.deletingLastPathComponent()
            .appendingPathComponent("\(username).realm")
        config.schemaVersion = defaultConfig.schemaVersion
        
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
}
