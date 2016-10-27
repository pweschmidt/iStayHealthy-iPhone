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
    let fileManager = FileManager.default
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
        do {
            try saveContext()
        }catch {}
        unregisterObservers()
    }
    
    func registerObservers()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(PWESPersistentStoreManager.mergeFromiCloud(_:)), name: NSNotification.Name.NSPersistentStoreDidImportUbiquitousContentChanges, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PWESPersistentStoreManager.iCloudStoreChanged(_:)), name: NSNotification.Name.NSUbiquityIdentityDidChange, object: nil)
    }
    
    func unregisterObservers()
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSPersistentStoreDidImportUbiquitousContentChanges, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSUbiquityIdentityDidChange, object: nil)
    }
    
    // MARK: configure the persistent store manager
    func configureStoreManager() -> Bool
    {
        let path:URL = Bundle.main.url(forResource: "iStayHealthy", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: path)
        if nil != model
        {
            persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model!)
            return configureContextForStore()
        }
        return false
    }
    
    func configureContextForStore() -> Bool
    {
        let type: NSMergePolicyType = NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType
        let policy: NSMergePolicy = NSMergePolicy(merge: type)
        let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
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
            setUpNewStore()
        }
        else
        {
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
        iCloudEnabled = false
        let libraryPath: URL = appLibraryDirectory()
        let newPath = libraryPath.appendingPathComponent(sqliteStoreName)
        let localOptions = CoreDataUtils.localStoreOptions()
        do {
            _ = try persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: newPath, options: localOptions)
        }catch{
            
        }
        
    }
    
    
    func setUpLegacyStore()
    {
        let manager = FileManager.default
        
        let iCloudToken = manager.ubiquityIdentityToken
        if nil != iCloudToken
        {
            setUpiCloudStore()
        }
        else
        {
            setUpNewStore()
        }
        
        
    }
    
    func setUpiCloudStore()
    {
        iCloudEnabled = true
        let queue: DispatchQueue = DispatchQueue(label: kBackgroundQueueName, attributes: [])
        let manager = FileManager.default
        var cloudPath = self.appDocumentDirectory().appendingPathComponent(oldStoreName)
        
        if !manager.fileExists(atPath: cloudPath.path)
        {
            let paths: NSMutableArray = NSMutableArray()
            self.searchPathForOldDataStore(oldStoreName, foundPaths: paths)
            if 0 < paths.count
            {
                if let firstFound = paths.firstObject as? String {
                    cloudPath = self.appDocumentDirectory().appendingPathComponent(firstFound)
                }
            }
        }
        
        queue.async(execute: { () -> Void in
            
            let iCloudStoreURL: URL? = manager.url(forUbiquityContainerIdentifier: kICloudTeamID)
            var options: [AnyHashable: Any]?
            if nil == iCloudStoreURL
            {
                options = CoreDataUtils.noiCloudStoreOptions()
            }
            else
            {
                options = CoreDataUtils.iCloudStoreOptions(withPath: iCloudStoreURL)
            }
            let coordinator = self.persistentStoreCoordinator!
            do {
                try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: cloudPath, options: options)
                DispatchQueue.main.async(execute: { () -> Void in
                    let notification = Notification(name: Notification.Name(rawValue: kLoadedStoreNotificationKey), object: self)
                    NotificationCenter.default.post(notification)
                })
                
            }catch{}
        })
        
    }
    
    func hasBackupFileWithContent() -> Bool
    {
        if !hasBackupFile()
        {
            return false
        }
        let filePath = getBackupFilePath()
        if nil == filePath
        {
            return false
        }
        let xmlReader = CoreXMLReader()
        let hasContent = xmlReader.hasContentForXML(withPath: filePath)
        return hasContent
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
    
    func getDataFromPath(_ path: String?) -> Data?
    {
        if nil == path
        {
            return nil
        }
        let data: Data? = try? Data(contentsOf: URL(fileURLWithPath: path!))
        
        return data
    }
    
    func hasNewDatabase() -> Bool
    {
        let libraryPath: URL = appLibraryDirectory()
        let newPath = libraryPath.appendingPathComponent(sqliteStoreName).path
        return fileManager.fileExists(atPath: newPath)
    }
    
    func hasLegacyDatabase() -> Bool
    {
        let documentPath: URL = appDocumentDirectory()
        let newPath = documentPath.appendingPathComponent(oldStoreName).path
        if self.fileManager.fileExists(atPath: newPath)
        {
            self.foundDatabasePaths.add(newPath)
            return true
        }
        else
        {
            let paths: NSMutableArray = NSMutableArray()
            searchPathForOldDataStore(oldStoreName, foundPaths: paths)
            if 0 < paths.count
            {
                self.foundDatabasePaths = paths
                return true
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
    
    func searchPathForOldDataStore(_ path: String, foundPaths:NSMutableArray)
    {
        let docPathURL: URL = appDocumentDirectory()
        let cloudPath = docPathURL.appendingPathComponent(coreDataPath)
        let path: String? = cloudPath.path
        var found = false
        if nil != path
        {
            found = self.fileManager.fileExists(atPath: path!)
        }
        
        if found
        {
            let directoryEnumerator = self.fileManager.enumerator(atPath: path!)
            
            while let element = directoryEnumerator?.nextObject() as? String
            {
                if element.hasSuffix(oldStoreName)
                {
                    foundPaths.add(element)
                }
            }
            
        }
    }
    
    
    func filePathInDocumentDirectory(_ filename: String) -> String?
    {
        let docPathURL: URL = appDocumentDirectory()
        let backupPath = docPathURL.appendingPathComponent(filename).path
        if fileManager.fileExists(atPath: backupPath) {
            return backupPath
        }
        else {
            return nil
        }
    }
    
    func appDocumentDirectory() -> URL
    {
        let paths = fileManager.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        let path = paths[paths.count - 1] 
        return path
    }
    
    func appLibraryDirectory() -> URL
    {
        let paths = fileManager.urls(for: FileManager.SearchPathDirectory.libraryDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        let path = paths[paths.count - 1] 
        return path
    }
    
    let context: NSManagedObjectContext =
    {
        let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        return context
        }()
    
    func disableiCloudStore(_ error: NSErrorPointer) -> Bool
    {
        if nil == defaultContext
        {
            return false
        }
//        defaultContext?.lock()
//        defaultContext?.reset()
        
        
        
        defaultContext?.performAndWait({ () -> Void in
            if let stores = self.persistentStoreCoordinator?.persistentStores {
                for store in stores
                {
                    do {
                        try self.persistentStoreCoordinator?.remove(store)
                    }catch{}
                }
            }
        })
        defaultContext?.reset()
        
        defaultContext = nil
        persistentStoreCoordinator = nil
        
        _ = configureStoreManager()
        //        defaultContext?.unlock()
        
        
        return true;
    }
    
    func setUpNewStoreWithBackupData(_ error: NSErrorPointer)
    {
        setUpNewStore()
        if hasBackupFile()
        {
            let docPath:URL = self.appDocumentDirectory()
            let filePath = docPath.appendingPathComponent(backupFileName)
            let importer = PWESCoreXMLImporter()
            importer.importWithURL(filePath, completionBlock: { (success, dictionary, error) -> Void in
                if success
                {
                    let dbImporter = PWESCoreDictionaryImporter()
                    do {
                        try dbImporter.saveToCoreData(dictionary)
                        
                    }catch {
                        
                    }
                }
            })
        }
    }
    
    func setiCloudEnabled(_ iCloud: Bool)
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
    func saveAndExport(_ completionBlock: @escaping PWESSuccessClosure)
    {
        do {
            try saveContext()
        }catch {
            let error = NSError(domain: "iStayHealthy", code: 103, userInfo: nil)
            completionBlock(false, error)
        }
        let hasBackup = hasBackupFileWithContent()
        if hasBackup
        {
            completionBlock(true, nil)
            return
        }
        
        let writer:CoreXMLWriter = CoreXMLWriter()
        writer.write(completionBlock: { (xmlString: String?, xmlError: Error?) -> Void in
            if nil != xmlString
            {
                let xml:NSString = xmlString! as NSString
                let xmlData: Data = xml.data(using: String.Encoding.utf8.rawValue)!
                let docPath:URL = self.appDocumentDirectory()
                let filePath = docPath.appendingPathComponent(backupFileName)
                let manager:FileManager = FileManager.default
                if manager.fileExists(atPath: filePath.path)
                {
                    do {
                        try manager.removeItem(at: filePath)
                    }catch {}
                }
                try? xmlData.write(to: filePath, options: [.atomic])
                completionBlock(true, nil)
            }
            else
            {
                completionBlock(false, xmlError as NSError?)
            }
        })
        
        return
    }
    
    func saveContext() throws {
        if let context = defaultContext {
            if !context.hasChanges {
                return
            }
            do {
                try context.save()
                let writer = CoreXMLWriter()
                writer.write(completionBlock: { (xmlString, xmlError) in
                    if let xml = xmlString {
                        let xmlData: Data = xml.data(using: String.Encoding.utf8)!
                        let docPath:URL = self.appDocumentDirectory()
                        let filePath = docPath.appendingPathComponent(backupFileName)
                        let manager:FileManager = FileManager.default
                        if manager.fileExists(atPath: filePath.path)
                        {
                            do {
                                try manager.removeItem(at: filePath)
                            }catch{
                            }
                        }
                        try? xmlData.write(to: filePath, options: [.atomic])
                        
                    }
                    
                })
            }catch {
                
            }
        } else {
            
        }
    }
    
//    func saveContext(_ error: NSErrorPointer) -> Bool
//    {
//        if nil == self.defaultContext
//        {
//            return false
//        }
//        let context: NSManagedObjectContext = defaultContext!
//        if !context.hasChanges
//        {
//            return true
//        }
//        
//        var success = true
//        success = context.save(error)
//        if !success
//        {
//            return false
//        }
//        
//        let writer:CoreXMLWriter = CoreXMLWriter()
//        writer.write(completionBlock: { (xmlString: String?, xmlError: NSError?) -> Void in
//            if nil != xmlString
//            {
//                let xml:NSString = xmlString!
//                let xmlData: Data = xml.data(using: String.Encoding.utf8)!
//                let docPath:URL = self.appDocumentDirectory()
//                var filePath = docPath.appendingPathComponent(backupFileName)
//                let manager:FileManager = FileManager.default
//                if manager.fileExists(atPath: filePath.path!)
//                {
//                    var fileError: NSError?
//                    manager.removeItemAtURL(filePath, error: &fileError)
//                }
//                try? xmlData.write(to: filePath, options: [.atomic])
//            }
//        })
//        
//        return true
//    }
    
    func fetchMasterRecord(_ completion: @escaping PWESArrayClosure)
    {
        fetchData(kiStayHealthyRecord, predicate: nil, sortTerm: nil, ascending: false, completion: completion)
    }
    
    func fetchData(_ entityName: String?, predicate: NSPredicate?, sortTerm: String?, ascending: Bool, completion: @escaping PWESArrayClosure)
    {
        if nil == self.defaultContext || nil == entityName
        {
            let coreDataError: NSError = NSError(domain: "CoreDataError", code: 100, userInfo: nil)
            completion(nil, coreDataError)
        }
        
        let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: entityName!, in: self.defaultContext!)!
        let request: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>()
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
        
        self.defaultContext?.perform({ () -> Void in
            do {
                let count = try self.defaultContext?.count(for: request)
                if 0 == count || NSNotFound == count {
                    completion([], nil)
                }
                else {
                    let fetchData = try self.defaultContext?.fetch(request)
                    completion(fetchData as NSArray?, nil)
                }
            } catch {
                let coreDataError: NSError = NSError(domain: "CoreDataError", code: 100, userInfo: nil)
                completion(nil, coreDataError)
            }
        })
        
    }
    
    func managedObjectForEntityName(_ entityName: String?) -> NSManagedObject?
    {
        if nil == self.defaultContext
        {
            return nil
        }
        if nil == entityName
        {
            return nil
        }
        let managedObject: AnyObject = NSEntityDescription.insertNewObject(forEntityName: entityName!, into: self.defaultContext!)
        return managedObject as? NSManagedObject
    }
    
    
    
    func removeManagedObject(_ managedObject: NSManagedObject?) throws
    {
        if let rmObject = managedObject {
            defaultContext?.delete(rmObject)
            do {
                try saveContext()
            }catch {
                
            }
        }
    }
    
    func loadDataFromBackupFile(_ completionBlock: @escaping PWESSuccessClosure)
    {
        var path: String?
        path = filePathInDocumentDirectory(backupFileName)
        if nil == path
        {
            let info = [NSLocalizedDescriptionKey : "No backup file found"]
            let error = NSError(domain: "com.pweschmidt.iStayHealthy", code: 102, userInfo: info)
            completionBlock(false, error)
            return
        }
        
        let pathURL = URL(fileURLWithPath: path!)
        let importer = PWESCoreXMLImporter()
        importer.importWithURL(pathURL, completionBlock: { (success, dictionary, error) -> Void in
            if !success || nil == dictionary
            {
                completionBlock(false, error)
            }
            else
            {
                let importSaver = PWESCoreDictionaryImporter()
                do {
                    try importSaver.saveToCoreData(dictionary)
                } catch {
                    completionBlock(false, NSError(domain: "iStayHealthy", code: 102, userInfo: nil))                    
                }
            }
        })
    }
    
    
    //MARK: notification responses
    func storeWillChange(_ notification: Notification?)
    {
        if nil == notification
        {
            return
        }
        let userInfo: Dictionary<String, AnyObject>? = (notification as NSNotification?)?.userInfo as? Dictionary<String, AnyObject>
        if nil == userInfo
        {
            return
        }
        let transitionType = userInfo?[NSPersistentStoreUbiquitousTransitionTypeKey] as? UInt
        
        let type = NSPersistentStoreUbiquitousTransitionType(rawValue: transitionType!)
        if NSPersistentStoreUbiquitousTransitionType.initialImportCompleted == type
        {
            
        }
        do {
            try saveContext()
        }catch {
        }
    }
    
    func storeDidChange(_ notification: Notification?)
    {
        if nil == notification
        {
            return
        }
        let userInfo: Dictionary<String, AnyObject>? = (notification as NSNotification?)?.userInfo as? Dictionary<String, AnyObject>
        if nil == userInfo
        {
            return
        }
        let transitionType = userInfo?[NSPersistentStoreUbiquitousTransitionTypeKey] as? UInt
        
        let type = NSPersistentStoreUbiquitousTransitionType(rawValue: transitionType!)
        if NSPersistentStoreUbiquitousTransitionType.initialImportCompleted == type
        {
            DispatchQueue.main.async(execute: { () -> Void in
                let localNotification = Notification(name: Notification.Name(rawValue: kLoadedStoreNotificationKey), object: self)
                NotificationCenter.default.post(localNotification)
            })
        }
    }
    
    
    func mergeFromiCloud(_ notification: Notification?)
    {
        if nil == defaultContext || nil == notification
        {
            return
        }
        defaultContext?.mergeChanges(fromContextDidSave: notification!)
        defaultContext?.processPendingChanges()
        do {
            try saveContext()
        }catch {
        }
    }
    
    func iCloudStoreChanged(_ notification: Notification?)
    {
        if nil == notification
        {
            return
        }
        
    }
    
}
