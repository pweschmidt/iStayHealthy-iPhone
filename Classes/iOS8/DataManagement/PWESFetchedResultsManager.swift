//
//  PWESFetchedResultsManager.swift
//  iStayHealthy
//
//  Created by Peter_Schmidt on 09/11/2014.
//
//

import UIKit
import CoreData

class PWESFetchedResultsManager: NSObject, NSFetchedResultsControllerDelegate
{
    let tableView: UITableView
    let updater: PWESTableViewUpdater
    let fetchControllerDictionary: NSMutableDictionary
    let sectionControllerDictionary: NSMutableDictionary
    
    init(tableView: UITableView, updater: PWESTableViewUpdater)
    {
        self.tableView = tableView
        self.updater = updater
        self.fetchControllerDictionary = NSMutableDictionary()
        self.sectionControllerDictionary = NSMutableDictionary()
        super.init()
    }
    

    func controllerWillChangeContent(controller: NSFetchedResultsController)
    {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController)
    {
        self.tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    {
        
        switch(type)
        {
        case NSFetchedResultsChangeType.Insert:
            let i = 0 //ahem - change this
        case NSFetchedResultsChangeType.Delete:
            let i = 0 //ahem - change this
        case NSFetchedResultsChangeType.Update:
            let i = 0 //ahem - change this
        case NSFetchedResultsChangeType.Move:
            let i = 0 //ahem - change this
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType)
    {
        switch(type)
        {
        case NSFetchedResultsChangeType.Insert:
            let i = 0 //ahem - change this
        case NSFetchedResultsChangeType.Delete:
            let i = 0 //ahem - change this
        case NSFetchedResultsChangeType.Update:
            let i = 0 //ahem - change this
        case NSFetchedResultsChangeType.Move:
            let i = 0 //ahem - change this
        }
    }
    
    func addControllerForModelClass(modelClass : AnyClass, predicate : NSPredicate, descriptors: NSArray, section: Int)
    {
        let entityName: NSString = NSStringFromClass(modelClass)
        let request: NSFetchRequest = entityRequest(entityName, predicate: predicate, descriptors: descriptors)
        
        
    }
    
    func addController(controller: NSFetchedResultsController, entityName : NSString, section : Int )
    {
        let sectionNumber: NSNumber = NSNumber(integer: section)
        self.fetchControllerDictionary.setObject(controller, forKey: entityName)
        self.sectionControllerDictionary.setObject(sectionNumber, forKey: entityName)
    }
    
    func removeController(entityName : NSString)
    {
        
    }
    
    func entityRequest(entityName: NSString, predicate: NSPredicate, descriptors: NSArray) -> NSFetchRequest
    {
        let request: NSFetchRequest = NSFetchRequest(entityName: entityName)
        request.fetchBatchSize = 20
        request.predicate = predicate
        request.sortDescriptors = descriptors
        return request
    }
    
    
    func sectionForController(controller : NSFetchedResultsController) -> Int
    {
        var section: Int = 0
        self.fetchControllerDictionary.enumerateKeysAndObjectsUsingBlock { (modelKey, fetchController, stop) -> Void in
            if(fetchController as NSFetchedResultsController == controller)
            {
                let sectionNumber: NSNumber = self.sectionControllerDictionary.objectForKey(modelKey) as NSNumber
                section = sectionNumber.integerValue
            }
        }
        return section
    }
    
    func controllerForEntityName(entityName : NSString) -> NSFetchedResultsController
    {
        var controller: NSFetchedResultsController = self.fetchControllerDictionary.objectForKey(entityName) as NSFetchedResultsController
        
        return controller
    }
}
