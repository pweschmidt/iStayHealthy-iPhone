//
//  PWESMigrationManager.swift
//  iStayHealthy
//
//  Created by Peter Schmidt on 13/09/2014.
//
//

import Foundation
import CoreData

class PWESMigrationManager: NSObject
{
    /**
    singleton
    */
    class var defaultManager : PWESMigrationManager
    {
        struct Static
        {
            static let instance : PWESMigrationManager = PWESMigrationManager()
        }
        return Static.instance
    }
}