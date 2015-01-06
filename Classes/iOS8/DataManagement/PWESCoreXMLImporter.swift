//
//  PWESCoreXMLImporter.swift
//  iStayHealthy
//
//  Created by Peter Schmidt on 06/01/2015.
//
//

import UIKit

class PWESCoreXMLImporter: NSObject, NSXMLParserDelegate
{
    var records: NSMutableDictionary = NSMutableDictionary()
    var results: NSMutableArray = NSMutableArray()
    var meds:NSMutableArray  = NSMutableArray()
    var otherMeds:NSMutableArray  = NSMutableArray()
    var procedures:NSMutableArray = NSMutableArray()
    var previousMeds:NSMutableArray = NSMutableArray()
    var effects:NSMutableArray = NSMutableArray()
    var clinics:NSMutableArray = NSMutableArray()
    var missedMeds:NSMutableArray = NSMutableArray()
    
    var completion: (Bool, NSMutableDictionary -> ())?
    
    func openImporterWithData(xmlData: NSData, completionBlock: (Bool, NSMutableDictionary -> ()))
    {
        self.completion = completionBlock
        let xmlParser: NSXMLParser = NSXMLParser(data: xmlData)
        xmlParser.parse()
    }
    
    
    
    func parserDidStartDocument(parser: NSXMLParser!)
    {
    }
    
    func parserDidEndDocument(parser: NSXMLParser!)
    {
        self.records.setValue(self.results, forKey: "Results")
        self.records.setValue(self.meds, forKey: "Medications")
        self.records.setValue(self.otherMeds, forKey: "OtherMedications")
        self.records.setValue(self.procedures, forKey: "Illnesses")
        self.records.setValue(self.previousMeds, forKey: "PreviousMedications")
        self.records.setValue(self.effects, forKey: "HIVSideEffects")
        self.records.setValue(self.clinics, forKey: "ClinicalContacts")
        self.records.setValue(self.missedMeds, forKey: "MissedMedications")
        if nil != self.completion
        {
        }
    }
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!)
    {
        if elementName == "Result"
        {
            self.results.addObject(attributeDict)
        }
        if elementName == "Medication"
        {
            self.meds.addObject(attributeDict)
        }
        if elementName == "MissedMedication"
        {
            self.missedMeds.addObject(attributeDict)
        }
        if elementName == "OtherMedication"
        {
            self.otherMeds.addObject(attributeDict)
        }
        if elementName == "Contacts"
        {
            self.clinics.addObject(attributeDict)
        }
        if elementName == "Procedures"
        {
            self.procedures.addObject(attributeDict)
        }
        if elementName == "SideEffects"
        {
            self.effects.addObject(attributeDict)
        }
        if elementName == "PreviousMedication"
        {
            self.previousMeds.addObject(attributeDict)
        }
    }
    
    
    func parser(parser: NSXMLParser!, parseErrorOccurred parseError: NSError!)
    {
        let result: Bool = false
    }
    
}
