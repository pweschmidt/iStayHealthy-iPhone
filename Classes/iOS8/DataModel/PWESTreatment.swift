//
//  PWESTreatment.swift
//  iStayHealthy
//
//  Created by Peter Schmidt on 13/09/2014.
//
//

import Foundation
import CoreData

class PWESTreatment: iStayHealthy.PWESHealthObject {

    @NSManaged var treatmentName: String
    @NSManaged var treatmentType: String
    @NSManaged var treatmentCause: String
    @NSManaged var sideEffects: NSSet
    @NSManaged var drugs: NSSet
    @NSManaged var interventions: NSSet
    @NSManaged var calendars: NSSet

}
