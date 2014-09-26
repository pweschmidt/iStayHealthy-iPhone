//
//  PWESMedicalIntervention.swift
//  iStayHealthy
//
//  Created by Peter Schmidt on 13/09/2014.
//
//

import Foundation
import CoreData

class PWESMedicalIntervention: iStayHealthy.PWESHealthObject {

    @NSManaged var interventionName: String
    @NSManaged var success: NSNumber
    @NSManaged var treatment: PWESTreatment

}
