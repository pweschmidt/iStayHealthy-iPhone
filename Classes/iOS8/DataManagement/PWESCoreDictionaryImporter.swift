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
    
    func saveToCoreData(_ record: NSDictionary?) throws
    {
        if nil == record
        {
            let error = NSError(domain: "iStayHealthy", code: 101, userInfo: nil)
            throw error
        }
        let result:[[String:String]]? = record?.object(forKey: kResults) as? [[String:String]]
        
        importFromArray(kResult, array: result)
        
        let meds:[[String:String]]? = record?.object(forKey: kMedications)  as? [[String:String]]
        importFromArray(kMedication, array: meds)

        let otherMeds:[[String:String]]? = record?.object(forKey: kOtherMedications) as? [[String:String]]
        importFromArray(kOtherMedication, array: otherMeds)

        let procedures:[[String:String]]? = record?.object(forKey: kIllnessAndProcedures) as? [[String:String]]
        importFromArray(kProcedures, array: procedures)

        let previousMeds:[[String:String]]? = record?.object(forKey: kPreviousMedications) as? [[String:String]]
        importFromArray(kPreviousMedication, array: previousMeds)

        let effects:[[String:String]]? = record?.object(forKey: kHIVSideEffects) as? [[String:String]]
        importFromArray(kSideEffects, array: effects)

        let clinics:[[String:String]]? = record?.object(forKey: kClinicalContacts) as? [[String:String]]
        importFromArray(kContacts, array: clinics)

        let missedMeds:[[String:String]]? = record?.object(forKey: kMissedMedications) as? [[String:String]]
        importFromArray(kMissedMedication, array: missedMeds)
        
        let manager = PWESPersistentStoreManager.defaultManager
        try! manager.saveContext()
        
    }
    
    func importFromArray(_ type: String, array: [[String:String]]?)
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
                let results = manager.managedObjectForEntityName(kResults) as! Results
                results.import(from: attributes)
            }
            else if kMedication == type
            {
                let meds = manager.managedObjectForEntityName(kMedication) as! Medication
                meds.import(from: attributes)
                
            }
            else if kOtherMedication == type
            {
                let meds = manager.managedObjectForEntityName(kOtherMedication) as! OtherMedication
                meds.import(from: attributes)
                
            }
            else if kProcedures == type
            {
                let procedures = manager.managedObjectForEntityName(kProcedures) as! Procedures
                procedures.import(from: attributes)
                
            }
            else if kPreviousMedication == type
            {
                let previous = manager.managedObjectForEntityName(kPreviousMedication) as! PreviousMedication
                previous.import(from: attributes)
                
            }
            else if kSideEffects == type
            {
                let effects = manager.managedObjectForEntityName(kSideEffects) as! SideEffects
                effects.import(from: attributes)
                
            }
            else if kMissedMedication == type
            {
                let missed = manager.managedObjectForEntityName(kMissedMedication) as! MissedMedication
                missed.import(from: attributes)
                
            }
            else if kContacts == type
            {
                let contacts = manager.managedObjectForEntityName(kContacts) as! Contacts
                contacts.import(from: attributes)
                
            }
        }
        
    }
   
}
