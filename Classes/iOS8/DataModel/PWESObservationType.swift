//
//  PWESObservationType.swift
//  iStayHealthy
//
//  Created by Peter Schmidt on 13/09/2014.
//
//

import Foundation
import CoreData

class PWESObservationType: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var added: NSDate
    @NSManaged var modified: NSDate

}
