//
//  PWESClinicAddress.swift
//  iStayHealthy
//
//  Created by Peter Schmidt on 13/09/2014.
//
//

import Foundation
import CoreData

class PWESClinicAddress: NSManagedObject {

    @NSManaged var email: String
    @NSManaged var web: String
    @NSManaged var street: String
    @NSManaged var city: String
    @NSManaged var country: String
    @NSManaged var postcode: String
    @NSManaged var clinic: PWESClinicalContact

}
