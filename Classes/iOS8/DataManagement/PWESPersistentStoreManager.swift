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

    class var defaultManager : PWESPersistentStoreManager
    {
        struct Static
        {
            static let instance : PWESPersistentStoreManager = PWESPersistentStoreManager()
        }
        return Static.instance
    }
    
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
    
    func setUpCoreDataStack()
    {
        let hasNewDB = hasNewDatabase()
        let hasOldDB = hasLegacyDatabase()
        
        let useNewDB = hasNewDB || (!hasNewDB && !hasOldDB)
        if useNewDB
        {
            setUpNewStore()
        }
        else
        {
            setUpLegacyStore()
        }
        
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
        if nil != persistentStoreCoordinator
        {
            let coordinator = persistentStoreCoordinator!
            let localOptions = CoreDataUtils.localStoreOptions()
            var creationError:NSError?
            var store = persistentStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: newPath, options: localOptions, error: &creationError)
        }
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
                var firstFound = paths.firstObject as String
                cloudPath = self.appDocumentDirectory().URLByAppendingPathComponent(firstFound)
            }
        }
        
        dispatch_async(queue, { () -> Void in
            
            let iCloudStoreURL: NSURL? = manager.URLForUbiquityContainerIdentifier(kICloudTeamID)
            var options: NSDictionary?
            if nil == iCloudStoreURL
            {
                options = CoreDataUtils.noiCloudStoreOptions()
            }
            else
            {
                options = CoreDataUtils.iCloudStoreOptionsWithPath(iCloudStoreURL)
            }
            var creationError:NSError?
            var store = self.persistentStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: cloudPath, options: options, error: &creationError)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let notification = NSNotification(name: kLoadedStoreNotificationKey, object: self)
                NSNotificationCenter.defaultCenter().postNotification(notification)
            })
        })
        
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
    
    func findStorageType() -> Int
    {
        if hasNewDatabase()
        {
            return 3
        }
        let hasBackup = hasBackupFile()
        var result: Int = hasBackup ? 2 : 1
        
        var oldPath: String? = pathOldDataStore()
        if nil != oldPath
        {
            return result
        }
        else
        {
            var paths: NSMutableArray = NSMutableArray()
            searchPathForOldDataStore(oldStoreName, foundPaths: paths)
            if 0 < paths.count
            {
                return result
            }
        }
        return 0
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
        let path = paths[paths.count - 1] as NSURL
        return path
    }
    
    func appLibraryDirectory() -> NSURL
    {
        let paths = self.fileManager.URLsForDirectory(NSSearchPathDirectory.LibraryDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        let path = paths[paths.count - 1] as NSURL
        return path
    }
    
    let context: NSManagedObjectContext =
    {
        let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        return context
    }()
    
    
    func save()
    {
        let error: NSErrorPointer = nil
        if self.context.hasChanges && !self.context.save(error)
        {
            
        }
    }
    
    func createHealthObject(className: NSString, error: NSErrorPointer) -> NSManagedObject
    {
        let entityDescription = NSEntityDescription.entityForName(className, inManagedObjectContext: self.context)
        
        let healthObject = NSManagedObject(entity: entityDescription!, insertIntoManagedObjectContext: self.context)
        
        return healthObject
    }
    
    
    func deleteObject(object: NSManagedObject) {
        self.context.deleteObject(object)
    }
    
    deinit
    {
        save()
    }
    
}
