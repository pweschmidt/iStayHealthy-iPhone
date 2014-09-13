//
//  PWESMedication.swift
//  iStayHealthy
//
//  Created by Peter Schmidt on 13/09/2014.
//
//

import Foundation
import CoreData

class PWESMedication: NSManagedObject {

    @NSManaged var brandNames: AnyObject
    @NSManaged var drugType: String
    @NSManaged var unit: String
    @NSManaged var image: NSData
    @NSManaged var treatment: PWESTreatment

}
