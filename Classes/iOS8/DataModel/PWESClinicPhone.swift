//
//  PWESClinicPhone.swift
//  iStayHealthy
//
//  Created by Peter Schmidt on 13/09/2014.
//
//

import Foundation
import CoreData

class PWESClinicPhone: NSManagedObject {

    @NSManaged var number: String
    @NSManaged var type: String
    @NSManaged var clinic: PWESClinicalContact
    @NSManaged var contact: PWESClinicContactRole

}
