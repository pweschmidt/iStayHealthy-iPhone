//
//  PWESClinicContactRole.swift
//  iStayHealthy
//
//  Created by Peter Schmidt on 13/09/2014.
//
//

import Foundation
import CoreData

class PWESClinicContactRole: NSManagedObject {

    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var role: String
    @NSManaged var clinic: PWESClinicalContact
    @NSManaged var phones: NSSet

}
