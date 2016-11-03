//
//  iStayHealthyAppDelegate.swift
//  iStayHealthy
//
//  Created by Schmidt, Peter (ELS) on 03/11/2016.
//
//

import UIKit
import SwiftyDropbox

@UIApplicationMain
class iStayHealthyAppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window?.tintColor = kTextColour
        let font = UIFont(type: FontType.Standard, size: FontSize(rawValue: 17)!)
        let navigationBarAppearance = [ NSForegroundColorAttributeName : kTextColour, NSFontAttributeName : font]
        UINavigationBar.appearance().titleTextAttributes = navigationBarAppearance
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        registerUserNotifications(application)
        
        _ = PWESPersistentStoreManager.defaultManager.setUpCoreDataStack()
        application.applicationIconBadgeNumber = 0
        DropboxClientsManager.setupWithAppKey(kDropboxConsumerKey)
        
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        do {
            try PWESPersistentStoreManager.defaultManager.saveContext()
        }catch {}
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if 0 < application.applicationIconBadgeNumber {
            application.applicationIconBadgeNumber = 0
        }
        
        let isPasswordEnabled = UserDefaults.standard.bool(forKey: kIsPasswordEnabled)
        if isPasswordEnabled {
            if let container = window?.rootViewController as? PWESContentContainerController {
                container.resetToLoginController()
            }
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if let authResult = DropboxClientsManager.handleRedirectURL(url) {
            switch authResult {
            case .success:
                print("Success! User is logged into Dropbox.")
            case .cancel:
                print("Authorization flow was manually canceled by user!")
            case .error(_, let description):
                print("Error: \(description)")
            }
            return true
        }
        else if url.isFileURL {
            let info = [kURLFilePathKey : url]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kImportCollectionNotificationKey), object: nil, userInfo: info)
            return true
        }
        else if let query = url.query {
            let urlImporter = PWESCoreURLImporter()
            let results = urlImporter.resultsFromURLQueryString(query) as? [String : Any]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kImportNotificationKey), object: nil, userInfo: results )
            return true
        }
        return false
    }
    
    
    
    
    func registerUserNotifications(_ application: UIApplication) {
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
    }
    
}
