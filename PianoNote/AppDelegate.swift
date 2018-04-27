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
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var orientationLock: UIInterfaceOrientationMask = .allButUpsideDown
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        application.registerForRemoteNotifications()
        _ = CloudManager.shared
        _ = LocalDatabase.shared
        _ = PianoNoteSizeInspector.shared
        performMigration()
//        let realm = try! Realm()
//        try? realm.write {
//            let notes = realm.objects(RealmNoteModel.self)
//            realm.delete(notes)
//        }

//        let newModel = RealmNoteModel.getNewModel(content: "", categoryRecordName: "")
//        ModelManager.saveNew(model: newModel)
        
        return true
    }
    
    func performMigration() {
        let url = Realm.Configuration.defaultConfiguration.fileURL
        let config = Realm.Configuration(
            fileURL: url,
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 28,
            
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientationLock
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
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

        
        if subscriptionID.hasSuffix(CKDatabaseScope.private.string) {
            CloudManager.shared.privateDatabase.handleNotification()
            completionHandler(.newData)
        } else if subscriptionID.hasSuffix(CKDatabaseScope.shared.string) {
            CloudManager.shared.sharedDatabase.handleNotification()
            completionHandler(.newData)
        } else if subscriptionID.hasPrefix(CKDatabaseScope.public.string) {
            CloudManager.shared.publicDatabase.handleNotification()
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
            print(error ?? "good")
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

