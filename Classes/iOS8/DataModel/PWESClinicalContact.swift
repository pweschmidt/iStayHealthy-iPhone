//
//  PWESClinicalContact.swift
//  iStayHealthy
//
//  Created by Peter Schmidt on 13/09/2014.
//
//

import Foundation
import CoreData

class PWESClinicalContact: PWESHealthObject {

    @NSManaged var name: String
    @NSManaged var clinicIdentifier: String
    @NSManaged var contacts: NSSet
    @NSManaged var addresses: NSSet
    @NSManaged var phones: NSSet

}
