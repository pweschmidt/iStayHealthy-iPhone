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
    
    var completion: PWESSuccessWithDictionaryClosure?
    
    func importWithURL(url: NSURL, completionBlock: PWESSuccessWithDictionaryClosure)
    {
        if !url.isFileReferenceURL()
        {
            let error = NSError(domain: "com.pweschmidt.iStayHealthy", code: 100, userInfo: nil)
            completionBlock(success: false, dictionary: nil, error: error)
            return
        }
        
        let xmlData = NSData(contentsOfURL: url)
        if nil != xmlData
        {
            importWithData(xmlData, completionBlock: completionBlock)
        }
    }
    
    
    func importWithData(xmlData: NSData?, completionBlock: PWESSuccessWithDictionaryClosure)
    {
        if nil == xmlData
        {
            let error = NSError(domain: "com.pweschmidt.iStayHealthy", code: 100, userInfo: nil)
            completionBlock(success: false, dictionary: nil, error: error)
            return
        }
        self.completion = completionBlock
        var validationError: NSError?
        let cleanedXMLData = CoreXMLTools.validatedXMLDataFromData(xmlData, error: &validationError)
        if nil != validationError || nil == cleanedXMLData
        {
            completionBlock(success: false, dictionary: nil, error: validationError)
            return
        }
        let xmlParser: NSXMLParser = NSXMLParser(data: cleanedXMLData)
        xmlParser.delegate = self
        xmlParser.parse()
    }
    
    func parserDidStartDocument(parser: NSXMLParser!)
    {
    }
    
    func parserDidEndDocument(parser: NSXMLParser!)
    {
        self.records.setObject(self.results, forKey: kResults)
        self.records.setObject(self.meds, forKey: kMedications)
        self.records.setObject(self.otherMeds, forKey: kOtherMedications)
        self.records.setObject(self.procedures, forKey: kIllnessAndProcedures)
        self.records.setObject(self.previousMeds, forKey: kPreviousMedications)
        self.records.setObject(self.effects, forKey: kHIVSideEffects)
        self.records.setObject(self.clinics, forKey: kClinicalContacts)
        self.records.setObject(self.missedMeds, forKey: kMissedMedications)
        if nil != self.completion
        {
            self.completion!(success: true, dictionary: self.records, error: nil)
        }
    }
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!)
    {
        if elementName == kResult
        {
            self.results.addObject(attributeDict)
        }
        if elementName == kMedication
        {
            self.meds.addObject(attributeDict)
        }
        if elementName == kMissedMedication
        {
            self.missedMeds.addObject(attributeDict)
        }
        if elementName == kOtherMedication
        {
            self.otherMeds.addObject(attributeDict)
        }
        if elementName == kContacts
        {
            self.clinics.addObject(attributeDict)
        }
        if elementName == kProcedures
        {
            self.procedures.addObject(attributeDict)
        }
        if elementName == kSideEffects
        {
            self.effects.addObject(attributeDict)
        }
        if elementName == kPreviousMedication
        {
            self.previousMeds.addObject(attributeDict)
        }
    }
    
    
    func parser(parser: NSXMLParser!, parseErrorOccurred parseError: NSError!)
    {
        if nil != self.completion
        {
            self.completion!(success: false, dictionary: nil, error: parseError)
        }
    }
    
}
