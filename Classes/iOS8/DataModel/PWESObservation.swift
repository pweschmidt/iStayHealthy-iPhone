//
//  PWESObservation.swift
//  iStayHealthy
//
//  Created by Peter Schmidt on 13/09/2014.
//
//

import Foundation
import CoreData

class PWESObservation: PWESHealthObject {

    @NSManaged var observationValue: NSNumber
    @NSManaged var observationType: String
    @NSManaged var observationNote: String
    @NSManaged var observationUnit: String

}
