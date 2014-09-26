//
//  PWESSideEffects.swift
//  iStayHealthy
//
//  Created by Peter Schmidt on 13/09/2014.
//
//

import Foundation
import CoreData

class PWESSideEffects: iStayHealthy.PWESHealthObject {

    @NSManaged var effectName: String
    @NSManaged var seriousIndex: NSNumber
    @NSManaged var frequencyIndex: String
    @NSManaged var treatment: PWESTreatment

}
