//
//  PWESCoreDictionaryImporter.swift
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/03/2015.
//
//

import UIKit

class PWESCoreDictionaryImporter: NSObject
{
    
    func saveToCoreData(record: NSDictionary?, error: NSErrorPointer) -> Bool
    {
        if nil == record
        {
            return false
        }
        var result:NSMutableArray? = record?.objectForKey(kResults) as? NSMutableArray
        
        importFromArray(kResult, array: result)
        
        var meds:NSMutableArray? = record?.objectForKey(kMedications)  as? NSMutableArray
        importFromArray(kMedication, array: meds)

        var otherMeds:NSMutableArray? = record?.objectForKey(kOtherMedications) as? NSMutableArray
        importFromArray(kOtherMedication, array: otherMeds)

        var procedures:NSMutableArray? = record?.objectForKey(kIllnessAndProcedures) as? NSMutableArray
        importFromArray(kProcedures, array: procedures)

        var previousMeds:NSMutableArray? = record?.objectForKey(kPreviousMedications) as? NSMutableArray
        importFromArray(kPreviousMedication, array: previousMeds)

        var effects:NSMutableArray? = record?.objectForKey(kHIVSideEffects) as? NSMutableArray
        importFromArray(kSideEffects, array: effects)

        var clinics:NSMutableArray? = record?.objectForKey(kClinicalContacts) as? NSMutableArray
        importFromArray(kContacts, array: clinics)

        var missedMeds:NSMutableArray? = record?.objectForKey(kMissedMedications) as? NSMutableArray
        importFromArray(kMissedMedication, array: missedMeds)
        
        return true
    }
    
    func importFromArray(type: String, array: NSMutableArray?)
    {
        if nil == array
        {
            return
        }
        if 0 == array?.count
        {
            return
        }
        
        let manager = PWESPersistentStoreManager.defaultManager
        
    }
   
}
