//
//  PWESCoreXMLImporter.swift
//  iStayHealthy
//
//  Created by Peter Schmidt on 06/01/2015.
//
//

import UIKit

class PWESCoreXMLImporter: NSObject, XMLParserDelegate
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
    
    var completion: PWESSuccessWithDictionaryClosure?
    
    func importWithURL(_ url: URL, completionBlock: @escaping PWESSuccessWithDictionaryClosure)
    {
        if !url.isFileURL
        {
            let error = NSError(domain: "com.pweschmidt.iStayHealthy", code: 100, userInfo: nil)
            completionBlock(false, nil, error)
            return
        }
        
        let xmlData = try? Data(contentsOf: url)
        if nil != xmlData
        {
            importWithData(xmlData, completionBlock: completionBlock)
        }
        else
        {
            let error = NSError(domain: "com.pweschmidt.iStayHealthy", code: 100, userInfo: nil)
            completionBlock(false, nil, error)
        }
    }
    
    
    func importWithData(_ xmlData: Data?, completionBlock: @escaping PWESSuccessWithDictionaryClosure)
    {
        if nil == xmlData
        {
            //            println("the data are NIL")
            let error = NSError(domain: "com.pweschmidt.iStayHealthy", code: 100, userInfo: nil)
            completionBlock(false, nil, error)
            return
        }
        self.completion = completionBlock
        var validationError: NSError?
        let cleanedXMLData = CoreXMLTools.validatedXMLDataFromData(xmlData, error: &validationError)
        if nil != validationError || nil == cleanedXMLData
        {
            //            println("the data cannot be validated")
            completionBlock(false, nil, validationError)
            return
        }
        let xmlParser: XMLParser = XMLParser(data: cleanedXMLData)
        xmlParser.delegate = self
        xmlParser.parse()
        //        println("parse")
    }
    
    func parserDidStartDocument(_ parser: XMLParser)
    {
        //        println("Start parsing document")
    }
    
    func parserDidEndDocument(_ parser: XMLParser)
    {
        //        println("End parsing document")
        self.records.setObject(self.results, forKey: kResults as NSCopying)
        self.records.setObject(self.meds, forKey: kMedications as NSCopying)
        self.records.setObject(self.otherMeds, forKey: kOtherMedications as NSCopying)
        self.records.setObject(self.procedures, forKey: kIllnessAndProcedures as NSCopying)
        self.records.setObject(self.previousMeds, forKey: kPreviousMedications as NSCopying)
        self.records.setObject(self.effects, forKey: kHIVSideEffects as NSCopying)
        self.records.setObject(self.clinics, forKey: kClinicalContacts as NSCopying)
        self.records.setObject(self.missedMeds, forKey: kMissedMedications as NSCopying)
        if nil != self.completion
        {
            self.completion!(true, self.records, nil)
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [AnyHashable: Any])
    {
        if elementName == kResult
        {
            self.results.add(attributeDict)
        }
        if elementName == kMedication
        {
            self.meds.add(attributeDict)
        }
        if elementName == kMissedMedication
        {
            self.missedMeds.add(attributeDict)
        }
        if elementName == kOtherMedication
        {
            self.otherMeds.add(attributeDict)
        }
        if elementName == kContacts
        {
            self.clinics.add(attributeDict)
        }
        if elementName == kProcedures
        {
            self.procedures.add(attributeDict)
        }
        if elementName == kSideEffects
        {
            self.effects.add(attributeDict)
        }
        if elementName == kPreviousMedication
        {
            self.previousMeds.add(attributeDict)
        }
    }
    
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error)
    {
        //        println("PARSER ERROR OCCURRED \(parseError)")
        if nil != self.completion
        {
            self.completion!(false, nil, parseError as NSError?)
        }
    }
    
}
