//
//  PWESAlert.swift
//  iStayHealthy
//
//  Created by Peter Schmidt on 13/09/2014.
//
//

import Foundation
import CoreData

class PWESAlert: iStayHealthy.PWESHealthObject {

    @NSManaged var name: String
    @NSManaged var frequencyIndex: NSNumber
    @NSManaged var soundName: String

}
