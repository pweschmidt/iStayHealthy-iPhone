//
//  PWESTreatmentCalendar.swift
//  iStayHealthy
//
//  Created by Peter Schmidt on 13/09/2014.
//
//

import Foundation
import CoreData

class PWESTreatmentCalendar: PWESHealthObject {

    @NSManaged var score: NSNumber
    @NSManaged var isComplete: NSNumber
    @NSManaged var treatment: PWESTreatment
    @NSManaged var entries: NSSet

}
