//
//  PWESHealthObject.swift
//  iStayHealthy
//
//  Created by Peter Schmidt on 13/09/2014.
//
//

import Foundation
import CoreData

class PWESHealthObject: NSManagedObject {

    @NSManaged var userID: String
    @NSManaged var added: NSDate
    @NSManaged var uuid: String
    @NSManaged var lastModified: NSDate
    @NSManaged var terminated: NSDate

}
