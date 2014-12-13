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
let jsonBackUpFile = "PWESHealth.json"
let oldStoreName = "iStayHealthy.sqlite"
let coreDataPath = "CoreDataUbiquitySupport"

class PWESPersistentStoreManager : NSObject
{
    var persistentStoreCoordinator: NSPersistentStoreCoordinator?
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
    
//    override init()
//    {
//        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
//        let fileManager = NSFileManager.defaultManager()
//        let paths = fileManager.URLsForDirectory(NSSearchPathDirectory.LibraryDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
//        let sqlPath:NSURL = paths[paths.count - 1] as NSURL
//        
//        let sqliteURL = sqlPath.URLByAppendingPathComponent(sqliteStoreName)
//        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
//        
//        let error:NSErrorPointer = nil
//        
//        let store = persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: sqliteURL, options: options, error: error)
//        
//        if (nil != store)
//        {
//            mainContext.persistentStoreCoordinator = persistentStoreCoordinator
//            hasLoadedStore = true
//        }
//        else
//        {
//            hasLoadedStore = false
//        }
//    }
    
    func setUpNewStore()
    {
        var model = self.iStayHealthyModel
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        if nil == self.persistentStoreCoordinator
        {
            
            
        }
    }
    
    func hasBackupFile() -> Bool
    {
        let searchResult = foundFileInDocumentDirectory(backupFileName)
        let found:Bool = searchResult.0
        return found
    }
    
    
    func pathOldDataStore() -> String?
    {
        let searchResult = foundFileInDocumentDirectory(oldStoreName)
        let found:Bool = searchResult.0
        var path: String?
        if found
        {
            return searchResult.1
        }
        else
        {
            
        }
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
    
    
    func foundFileInDocumentDirectory(filename: String) -> (Bool, String?)
    {
        var found = false
        var path: String?
        
        var docPathURL: NSURL = appDocumentDirectory()
        var backupPath = docPathURL.URLByAppendingPathComponent(filename)
        path = backupPath.path
        if nil != path
        {
            found = self.fileManager.fileExistsAtPath(path!)
        }
        return (found, path)
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
    
    ///in case we want to create a context hierarchy as before
//    let parentContext: NSManagedObjectContext =
//    {
//        let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
//        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//        return context
//    }()
    
    let context: NSManagedObjectContext =
    {
        let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        return context
    }()
    
    let iStayHealthyModel:NSManagedObjectModel =
    {
        let path:NSURL = NSBundle.mainBundle().URLForResource("iStayHealthy", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOfURL: path)
        return model!
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
