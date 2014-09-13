//
//  PWESTreatmentCalendarEntry.swift
//  iStayHealthy
//
//  Created by Peter Schmidt on 13/09/2014.
//
//

import Foundation
import CoreData

class PWESTreatmentCalendarEntry: PWESHealthObject {

    @NSManaged var entryIndex: NSNumber
    @NSManaged var calendar: PWESTreatmentCalendar

}
