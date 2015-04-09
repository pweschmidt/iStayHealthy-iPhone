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
        var result:[[String:String]]? = record?.objectForKey(kResults) as? [[String:String]]
        
        importFromArray(kResult, array: result)
        
        var meds:[[String:String]]? = record?.objectForKey(kMedications)  as? [[String:String]]
        importFromArray(kMedication, array: meds)

        var otherMeds:[[String:String]]? = record?.objectForKey(kOtherMedications) as? [[String:String]]
        importFromArray(kOtherMedication, array: otherMeds)

        var procedures:[[String:String]]? = record?.objectForKey(kIllnessAndProcedures) as? [[String:String]]
        importFromArray(kProcedures, array: procedures)

        var previousMeds:[[String:String]]? = record?.objectForKey(kPreviousMedications) as? [[String:String]]
        importFromArray(kPreviousMedication, array: previousMeds)

        var effects:[[String:String]]? = record?.objectForKey(kHIVSideEffects) as? [[String:String]]
        importFromArray(kSideEffects, array: effects)

        var clinics:[[String:String]]? = record?.objectForKey(kClinicalContacts) as? [[String:String]]
        importFromArray(kContacts, array: clinics)

        var missedMeds:[[String:String]]? = record?.objectForKey(kMissedMedications) as? [[String:String]]
        importFromArray(kMissedMedication, array: missedMeds)
        
        let manager = PWESPersistentStoreManager.defaultManager
        manager.saveContext(error)
        
        return true
    }
    
    func importFromArray(type: String, array: [[String:String]]?)
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
        for attributes in array!
        {
            if kResult == type
            {
                let results = manager.managedObjectForEntityName(kResult) as! Results
                results.importFromDictionary(attributes)
            }
            else if kMedication == type
            {
                let meds = manager.managedObjectForEntityName(kMedication) as! Medication
                meds.importFromDictionary(attributes)
                
            }
            else if kOtherMedication == type
            {
                let meds = manager.managedObjectForEntityName(kOtherMedication) as! OtherMedication
                meds.importFromDictionary(attributes)
                
            }
            else if kProcedures == type
            {
                let procedures = manager.managedObjectForEntityName(kProcedures) as! Procedures
                procedures.importFromDictionary(attributes)
                
            }
            else if kPreviousMedication == type
            {
                let previous = manager.managedObjectForEntityName(kPreviousMedication) as! PreviousMedication
                previous.importFromDictionary(attributes)
                
            }
            else if kSideEffects == type
            {
                let effects = manager.managedObjectForEntityName(kSideEffects) as! SideEffects
                effects.importFromDictionary(attributes)
                
            }
            else if kMissedMedication == type
            {
                let missed = manager.managedObjectForEntityName(kMissedMedication) as! MissedMedication
                missed.importFromDictionary(attributes)
                
            }
            else if kContacts == type
            {
                let contacts = manager.managedObjectForEntityName(kContacts) as! Contacts
                contacts.importFromDictionary(attributes)
                
            }
        }
        
    }
   
}
