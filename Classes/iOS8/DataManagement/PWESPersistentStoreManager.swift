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

class PWESPersistentStoreManager : NSObject
{
    let persistentStoreCoordinator: NSPersistentStoreCoordinator
    let hasLoadedStore: Bool

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
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let fileManager = NSFileManager.defaultManager()
        let paths = fileManager.URLsForDirectory(NSSearchPathDirectory.LibraryDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        let sqlPath:NSURL = paths[paths.count - 1] as NSURL
        
        let sqliteURL = sqlPath.URLByAppendingPathComponent(sqliteStoreName)
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        
        let error:NSErrorPointer = nil
        
        let store = persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: sqliteURL, options: options, error: error)
        
        if (nil != store)
        {
            mainContext.persistentStoreCoordinator = persistentStoreCoordinator
            hasLoadedStore = true
        }
        else
        {
            hasLoadedStore = false
        }
    }
    
    
    ///in case we want to create a context hierarchy as before
    let parentContext: NSManagedObjectContext =
    {
        let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    let mainContext: NSManagedObjectContext =
    {
        let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        return context
    }()
    
    let model:NSManagedObjectModel =
    {
        let path:NSURL = NSBundle.mainBundle().URLForResource("PWESHealth", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOfURL: path)
        return model!
    }()
    
    func save()
    {
        let context = mainContext
        context.performBlockAndWait
        {
            let error: NSErrorPointer = nil
            if context.hasChanges && !context.save(error)
            {
                
            }
        }
    }
    
    func createHealthObject(className: NSString, error: NSErrorPointer) -> NSManagedObject
    {
        let entityDescription = NSEntityDescription.entityForName(className, inManagedObjectContext: mainContext)
        
        let healthObject = NSManagedObject(entity: entityDescription!, insertIntoManagedObjectContext: mainContext)
        
        return healthObject
    }
    
    
    func deleteObject(object: NSManagedObject) {
        let context = mainContext
        context.performBlockAndWait
        {
            context.deleteObject(object)
        }
    }
    
    deinit
    {
        save()
    }
    
}
