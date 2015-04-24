//
//  PWESPersistentStoreManager.swift
//  iStayHealthy
//
//  Created by Peter Schmidt on 13/09/2014.
//
//

import Foundation
import CoreData

let sqliteStoreName = "PWESiStayHealthy.sqlite"
let backupFileName = "iStayHealthyBackup.xml"
let jsonBackUpFile = "PWESHealthy.json"
let oldStoreName = "iStayHealthy.sqlite"
let coreDataPath = "CoreDataUbiquitySupport"

class PWESPersistentStoreManager : NSObject
{
    var foundDatabasePaths: NSMutableArray = NSMutableArray()
    var persistentStoreCoordinator: NSPersistentStoreCoordinator?
    var defaultContext: NSManagedObjectContext?
    var hasLoadedStore: Bool?
    let fileManager = NSFileManager.defaultManager()
    var iCloudEnabled: Bool?

    // MARK: init/declare
    class var defaultManager : PWESPersistentStoreManager
    {
        struct Static
        {
            static let instance : PWESPersistentStoreManager = PWESPersistentStoreManager()
        }
        return Static.instance
    }
    
    override init()
    {
        super.init()
        iCloudEnabled = false;
        registerObservers()
    }
    
    deinit
    {
        saveContext(nil)
        unregisterObservers()
    }
    
    func registerObservers()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "mergeFromiCloud:", name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "iCloudStoreChanged:", name: NSUbiquityIdentityDidChangeNotification, object: nil)
    }
    
    func unregisterObservers()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSUbiquityIdentityDidChangeNotification, object: nil)
    }
    
    // MARK: configure the persistent store manager
    func configureStoreManager() -> Bool
    {
        let path:NSURL = NSBundle.mainBundle().URLForResource("iStayHealthy", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOfURL: path)
        if nil != model
        {
            persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model!)
            return configureContextForStore()
        }
        return false
    }
    
    func configureContextForStore() -> Bool
    {
        let type: NSMergePolicyType = NSMergePolicyType.MergeByPropertyObjectTrumpMergePolicyType
        let policy: NSMergePolicy = NSMergePolicy(mergeType: type)
        let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        if nil != persistentStoreCoordinator
        {
            context.persistentStoreCoordinator = persistentStoreCoordinator
            context.mergePolicy = policy
            defaultContext = context
            return true
        }
        return false
    }
    
    // MARK: sets up the core data stack
    func setUpCoreDataStack() -> Bool
    {
        let hasSetUpManager = configureStoreManager()
        if !hasSetUpManager
        {
            return false
        }
        let hasNewDB = hasNewDatabase()
        let hasOldDB = hasLegacyDatabase()
        
        let useNewDB = hasNewDB || (!hasNewDB && !hasOldDB)
        if useNewDB
        {
            iCloudEnabled = false
            setUpNewStore()
        }
        else
        {
            iCloudEnabled = true
            setUpLegacyStore()
        }
        return true
    }
    
    func setUpNewStore()
    {
        if nil == persistentStoreCoordinator
        {
            return
        }
        var path: String?
        var libraryPath: NSURL = appLibraryDirectory()
        var newPath = libraryPath.URLByAppendingPathComponent(sqliteStoreName)
        let coordinator = persistentStoreCoordinator!
        let localOptions = CoreDataUtils.localStoreOptions()
        var creationError:NSError? = nil
        var store = persistentStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: newPath, options: localOptions, error: &creationError)
        println("WE ARE SETTING UP THE NEW STORE IN THE LIBRARY FOLDER \(newPath)")
    }
    
    
    func setUpLegacyStore()
    {
        let manager = NSFileManager.defaultManager()
        
        var iCloudToken = manager.ubiquityIdentityToken
        if nil != iCloudToken
        {
            self.setUpiCloudStore()
        }
        
        
    }
    
    func setUpiCloudStore()
    {
        let queue: dispatch_queue_t = dispatch_queue_create(kBackgroundQueueName, nil)
        let manager = NSFileManager.defaultManager()
        var cloudPath = self.appDocumentDirectory().URLByAppendingPathComponent(oldStoreName)
        
        if !manager.fileExistsAtPath(cloudPath.path!)
        {
            var paths: NSMutableArray = NSMutableArray()
            self.searchPathForOldDataStore(oldStoreName, foundPaths: paths)
            if 0 < paths.count
            {
                var firstFound = paths.firstObject as! String
                cloudPath = self.appDocumentDirectory().URLByAppendingPathComponent(firstFound)
            }
        }
        
        dispatch_async(queue, { () -> Void in
            
            let iCloudStoreURL: NSURL? = manager.URLForUbiquityContainerIdentifier(kICloudTeamID)
            var options: [NSObject : AnyObject]?
            if nil == iCloudStoreURL
            {
                options = CoreDataUtils.noiCloudStoreOptions()
            }
            else
            {
                options = CoreDataUtils.iCloudStoreOptionsWithPath(iCloudStoreURL)
            }
            var creationError: NSError?
            let coordinator = self.persistentStoreCoordinator!
            coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: cloudPath, options: options, error: &creationError)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let notification = NSNotification(name: kLoadedStoreNotificationKey, object: self)
                NSNotificationCenter.defaultCenter().postNotification(notification)
            })
        })
        
    }
    
    func hasBackupFile() -> Bool
    {
        var path: String?
        path = filePathInDocumentDirectory(backupFileName)
        if nil != path
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func getBackupFilePath() -> String?
    {
        var path: String?
        path = filePathInDocumentDirectory(backupFileName)
        return path
    }
    
    func getDataFromPath(path: String?) -> NSData?
    {
        if nil == path
        {
            return nil
        }
        var data: NSData? = NSData(contentsOfFile: path!)
        
        return data
    }
    
    func hasNewDatabase() -> Bool
    {
        var path: String?
        var libraryPath: NSURL = appLibraryDirectory()
        var newPath = libraryPath.URLByAppendingPathComponent(sqliteStoreName)
        if nil != newPath.path
        {
            if self.fileManager.fileExistsAtPath(newPath.path!)
            {
                return true
            }
        }
        return false
    }
    
    func hasLegacyDatabase() -> Bool
    {
        var path: String?
        var libraryPath: NSURL = appLibraryDirectory()
        var newPath = libraryPath.URLByAppendingPathComponent(oldStoreName)
        if nil != newPath.path
        {
            if self.fileManager.fileExistsAtPath(newPath.path!)
            {
                self.foundDatabasePaths.addObject(newPath)
                return true
            }
            else
            {
                var paths: NSMutableArray = NSMutableArray()
                searchPathForOldDataStore(oldStoreName, foundPaths: paths)
                if 0 < paths.count
                {
                    self.foundDatabasePaths = paths
                    return true
                }
            }
        }
        return false;
    }
    
    func pathOldDataStore() -> String?
    {
        var path: String?
        path = filePathInDocumentDirectory(oldStoreName)
        return path
    }
    
    func searchPathForOldDataStore(path: String, foundPaths:NSMutableArray)
    {
        var docPathURL: NSURL = appDocumentDirectory()
        var cloudPath = docPathURL.URLByAppendingPathComponent(coreDataPath)
        var path: String? = cloudPath.path
        var found = false
        if nil != path
        {
            found = self.fileManager.fileExistsAtPath(path!)
        }
        
        if found
        {
            let directoryEnumerator = self.fileManager.enumeratorAtPath(path!)
            
            while let element = directoryEnumerator?.nextObject() as? String
            {
                if element.hasSuffix(oldStoreName)
                {
                    foundPaths.addObject(element)
                }
            }
            
        }
    }
    
    
    func filePathInDocumentDirectory(filename: String) -> String?
    {
        var path: String?
        var docPathURL: NSURL = appDocumentDirectory()
        var backupPath = docPathURL.URLByAppendingPathComponent(filename)
        if nil != backupPath.path
        {
            if self.fileManager.fileExistsAtPath(backupPath.path!)
            {
                path = backupPath.path
            }
        }
        return path
    }
    
    func appDocumentDirectory() -> NSURL
    {
        let paths = self.fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        let path = paths[paths.count - 1] as! NSURL
        return path
    }
    
    func appLibraryDirectory() -> NSURL
    {
        let paths = self.fileManager.URLsForDirectory(NSSearchPathDirectory.LibraryDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        let path = paths[paths.count - 1] as! NSURL
        return path
    }
    
    let context: NSManagedObjectContext =
    {
        let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        return context
        }()
    
    func disableiCloudStore(error: NSErrorPointer) -> Bool
    {
        if nil == defaultContext
        {
            return false
        }
//        defaultContext?.lock()
//        defaultContext?.reset()
        defaultContext?.performBlockAndWait({ () -> Void in
            let stores = self.persistentStoreCoordinator?.persistentStores as! [NSPersistentStore];
            for store in stores
            {
                self.persistentStoreCoordinator?.removePersistentStore(store, error: nil)
            }
        })
        defaultContext?.reset()
        
        defaultContext = nil
        persistentStoreCoordinator = nil
        
        configureStoreManager()
        //        defaultContext?.unlock()
        
        
        return true;
    }
    
    func setUpNewStoreWithBackupData(error: NSErrorPointer)
    {
        setUpNewStore()
        if hasBackupFile()
        {
            let docPath:NSURL = self.appDocumentDirectory()
            var filePath = docPath.URLByAppendingPathComponent(backupFileName)
            let importer = PWESCoreXMLImporter()
            importer.importWithURL(filePath, completionBlock: { (success, dictionary, error) -> Void in
                if success
                {
                    let dbImporter = PWESCoreDictionaryImporter()
                    var saveError: NSError?
                    dbImporter.saveToCoreData(dictionary, error: &saveError)
                }
            })
        }
    }
    
    func setiCloudEnabled(iCloud: Bool)
    {
        iCloudEnabled = iCloud
    }
    
    func storeIsiCloudEnabled() -> Bool
    {
        if nil == iCloudEnabled
        {
            return false
        }
        return iCloudEnabled!
    }

    // MARK: Core data main functions
    func saveAndExport(error: NSErrorPointer, completionBlock: PWESSuccessClosure) -> Bool
    {
        if nil == defaultContext
        {
            completionBlock(success: false, error: nil)
            return false
        }
        let context: NSManagedObjectContext = defaultContext!
        var success = true
        success = context.save(error)
        var hasBackup = hasBackupFile()
        if hasBackup
        {
            completionBlock(success: true, error: nil)
            return true
        }
        
        let writer:CoreXMLWriter = CoreXMLWriter()
        writer.writeWithCompletionBlock({ (xmlString: String?, xmlError: NSError?) -> Void in
            if nil != xmlString
            {
                let xml:NSString = xmlString!
                let xmlData: NSData = xml.dataUsingEncoding(NSUTF8StringEncoding)!
                let docPath:NSURL = self.appDocumentDirectory()
                var filePath = docPath.URLByAppendingPathComponent(backupFileName)
                let manager:NSFileManager = NSFileManager.defaultManager()
                if manager.fileExistsAtPath(filePath.path!)
                {
                    var fileError: NSError?
                    manager.removeItemAtURL(filePath, error: &fileError)
                }
                xmlData.writeToURL(filePath, atomically: true)
                completionBlock(success: true, error: nil)
            }
            else
            {
                completionBlock(success: false, error: xmlError)
            }
        })
        
        return true
    }
    
    
    func saveContext(error: NSErrorPointer) -> Bool
    {
        if nil == self.defaultContext
        {
            return false
        }
        let context: NSManagedObjectContext = defaultContext!
        if !context.hasChanges
        {
            return true
        }
        
        var success = true
        success = context.save(error)
        if !success
        {
            return false
        }
        
        let writer:CoreXMLWriter = CoreXMLWriter()
        writer.writeWithCompletionBlock({ (xmlString: String?, xmlError: NSError?) -> Void in
            if nil != xmlString
            {
                let xml:NSString = xmlString!
                let xmlData: NSData = xml.dataUsingEncoding(NSUTF8StringEncoding)!
                let docPath:NSURL = self.appDocumentDirectory()
                var filePath = docPath.URLByAppendingPathComponent(backupFileName)
                let manager:NSFileManager = NSFileManager.defaultManager()
                if manager.fileExistsAtPath(filePath.path!)
                {
                    var fileError: NSError?
                    manager.removeItemAtURL(filePath, error: &fileError)
                }
                xmlData.writeToURL(filePath, atomically: true)
            }
        })
        
        return true
    }
    
    func fetchMasterRecord(completion: PWESArrayClosure)
    {
        fetchData(kiStayHealthyRecord, predicate: nil, sortTerm: nil, ascending: false, completion: completion)
    }
    
    func fetchData(entityName: String?, predicate: NSPredicate?, sortTerm: String?, ascending: Bool, completion: PWESArrayClosure)
    {
        if nil == self.defaultContext || nil == entityName
        {
            var coreDataError: NSError = NSError(domain: "CoreDataError", code: 100, userInfo: nil)
            completion(array:nil, error:coreDataError)
        }
        
        let entity: NSEntityDescription = NSEntityDescription.entityForName(entityName!, inManagedObjectContext: self.defaultContext!)!
        let request: NSFetchRequest = NSFetchRequest()
        request.entity = entity
        
        if nil != predicate
        {
            request.predicate = predicate
        }
        
        if nil != sortTerm
        {
            let descriptor: NSSortDescriptor = NSSortDescriptor(key: sortTerm!, ascending: ascending)
            request.sortDescriptors = [descriptor]
        }
        
        self.defaultContext?.performBlock({ () -> Void in
            var fetchError: NSError?
            let count = self.defaultContext?.countForFetchRequest(request, error: &fetchError)
            if 0 == count || NSNotFound == count
            {
                let emptyData = []
                completion(array: emptyData, error: nil)
            }
            else
            {
                let fetchedObjects = self.defaultContext?.executeFetchRequest(request, error: &fetchError)
                completion(array: fetchedObjects, error: fetchError)
            }
        })
        
    }
    
    func managedObjectForEntityName(entityName: String?) -> NSManagedObject?
    {
        if nil == self.defaultContext
        {
            return nil
        }
        if nil == entityName
        {
            return nil
        }
        var managedObject: AnyObject = NSEntityDescription.insertNewObjectForEntityForName(entityName!, inManagedObjectContext: self.defaultContext!)
        return managedObject as? NSManagedObject
    }
    
    
    
    func removeManagedObject(managedObject: NSManagedObject?, error: NSErrorPointer) -> Bool
    {
        if nil == managedObject
        {
            return true
        }
        defaultContext!.deleteObject(managedObject!)
        let success = self.saveContext(error)
        return success
    }
    
    func loadDataFromBackupFile(completionBlock: PWESSuccessClosure)
    {
        var path: String?
        path = filePathInDocumentDirectory(backupFileName)
        if nil == path
        {
            let info = [NSLocalizedDescriptionKey : "No backup file found"]
            let error = NSError(domain: "com.pweschmidt.iStayHealthy", code: 102, userInfo: info)
            completionBlock(success: false, error: error)
            return
        }
        
        let pathURL = NSURL(fileURLWithPath: path!)
        if nil == pathURL
        {
            let info = [NSLocalizedDescriptionKey : "No backup file found"]
            let error = NSError(domain: "com.pweschmidt.iStayHealthy", code: 102, userInfo: info)
            completionBlock(success: false, error: error)
            return
        }
        let importer = PWESCoreXMLImporter()
        importer.importWithURL(pathURL!, completionBlock: { (success, dictionary, error) -> Void in
            if !success || nil == dictionary
            {
                completionBlock(success: false, error: error)
            }
            else
            {
                let importSaver = PWESCoreDictionaryImporter()
                var importError: NSError?
                let importSuccess = importSaver.saveToCoreData(dictionary, error: &importError)
                completionBlock(success: importSuccess, error: importError)
            }
        })
    }
    
    
    //MARK: notification responses
    func storeWillChange(notification: NSNotification?)
    {
        if nil == notification
        {
            return
        }
        let userInfo: Dictionary<String, AnyObject>? = notification?.userInfo as? Dictionary<String, AnyObject>
        if nil == userInfo
        {
            return
        }
        let transitionType = userInfo?[NSPersistentStoreUbiquitousTransitionTypeKey] as? UInt
        
        let type = NSPersistentStoreUbiquitousTransitionType(rawValue: transitionType!)
        if NSPersistentStoreUbiquitousTransitionType.InitialImportCompleted == type
        {
            
        }
        var error: NSError?
        saveContext(&error)
    }
    
    func storeDidChange(notification: NSNotification?)
    {
        if nil == notification
        {
            return
        }
        let userInfo: Dictionary<String, AnyObject>? = notification?.userInfo as? Dictionary<String, AnyObject>
        if nil == userInfo
        {
            return
        }
        let transitionType = userInfo?[NSPersistentStoreUbiquitousTransitionTypeKey] as? UInt
        
        let type = NSPersistentStoreUbiquitousTransitionType(rawValue: transitionType!)
        if NSPersistentStoreUbiquitousTransitionType.InitialImportCompleted == type
        {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let localNotification = NSNotification(name: kLoadedStoreNotificationKey, object: self)
                NSNotificationCenter.defaultCenter().postNotification(localNotification)
            })
        }
    }
    
    
    func mergeFromiCloud(notification: NSNotification?)
    {
        if nil == defaultContext || nil == notification
        {
            return
        }
        defaultContext!.mergeChangesFromContextDidSaveNotification(notification!)
        defaultContext!.processPendingChanges()
        var error: NSError?
        saveContext(&error)
    }
    
    func iCloudStoreChanged(notification: NSNotification?)
    {
        if nil == notification
        {
            return
        }
        
    }
    
}
