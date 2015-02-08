//
//  PWESCoreURLImporter.swift
//  iStayHealthy
//
//  Created by Peter_Schmidt on 18/01/2015.
//
//

import UIKit

class PWESCoreURLImporter: NSObject
{
    var results: NSMutableDictionary = NSMutableDictionary()

    func resultsFromURLQueryString(queryString: String) -> NSDictionary
    {
        let queryComponents = queryString.componentsSeparatedByString("&")
        for component in queryComponents
        {
            let individualComponent = component.componentsSeparatedByString("=")
            if 2 == individualComponent.count
            {
                var mappedKeyString: String = mapResultsType(individualComponent[0])
                var valueString = individualComponent[1]
                println("key = \(mappedKeyString) and value = \(valueString)")
                resultsAttributeDictionary(mappedKeyString, valueString: valueString)
            }
        }
        return results
    }
    
    func resultsAttributeDictionary(keyString: String, valueString: String)
    {
        if keyString == "Unknown"
        {
            return
        }
        if "BloodPressure" == keyString
        {
            bloodPressureFromString(valueString)
        }
        else if kResultsDate == keyString
        {
            dateFromStringValue(valueString)
        }
        else
        {
            numberFromStringValue(keyString, valueString: valueString)
        }
    }
    
    func numberFromStringValue(keyString: String, valueString: String)
    {
        println("***** numberFromStringValue with key='\(keyString)' and value=\(valueString)")
        var value:NSNumber?
        if "undetectable" == valueString
        {
            value = NSNumber(float: 1)
            println("we have undetectable = \(value)")
            results.setObject(value!, forKey: keyString)
            return
        }

        var candidate: Float = (valueString as NSString).floatValue
        value = NSNumber(float: candidate)
        if nil != value
        {
            println("added value \(value) to dictionary")
            results.setObject(value!, forKey: keyString)
        }
        else
        {
            println("couldn't add valuestring to dictionary")
        }
    }
    
    func dateFromStringValue(dateString: String)
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMMyyyy"
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        var value: NSDate? = formatter.dateFromString(dateString)
        println("found date = \(value)")
        if nil != value
        {
            results.setObject(value!, forKey: kResultsDate)
        }
    }
    
    func bloodPressureFromString(bloodPressureString: String)
    {
        var components = bloodPressureString.componentsSeparatedByString("-")
        if 2 == components.count
        {
            let systoleString = components[0]
            let diastoleString = components[1]
            var systole:NSNumber?
            var diastole:NSNumber?
            var candidate: Float = (systoleString as NSString).floatValue
            systole = NSNumber(float: candidate)
            candidate = (diastoleString as NSString).floatValue
            diastole = NSNumber(float: candidate)
            
            if nil != systole && nil != diastole
            {
                results.setObject(systole!, forKey: kSystole)
                results.setObject(diastole!, forKey: kDiastole)
            }
        }
    }
    
    func addResultsData(keyString: String, value: AnyObject?)
    {
        results.setObject(value!, forKey: keyString)
    }
    
    func mapResultsType(type:String) -> String
    {
        if NSComparisonResult.OrderedSame == type.caseInsensitiveCompare(kCD4)
        {
            return kCD4;
        }
        else if NSComparisonResult.OrderedSame == type.caseInsensitiveCompare(kCD4Percent)
        {
            return kCD4Percent
        }
        else if NSComparisonResult.OrderedSame == type.caseInsensitiveCompare(kViralLoad)
        {
            return kViralLoad
        }
        else if NSComparisonResult.OrderedSame == type.caseInsensitiveCompare(kResultsDate) ||
       NSComparisonResult.OrderedSame == type.caseInsensitiveCompare("ResultDate") ||
        NSComparisonResult.OrderedSame == type.caseInsensitiveCompare("date")
        {
            return kResultsDate
        }
        else if NSComparisonResult.OrderedSame == type.caseInsensitiveCompare("BloodPressure")
        {
            return "BloodPressure"
        }
        else if NSComparisonResult.OrderedSame == type.caseInsensitiveCompare(kBMI)
        {
            return kBMI
        }
        else if NSComparisonResult.OrderedSame == type.caseInsensitiveCompare("CardiacRisk")
        {
            return kCardiacRiskFactor
        }
        else if NSComparisonResult.OrderedSame == type.caseInsensitiveCompare("Cholesterol")
        {
            return kTotalCholesterol
        }
        
        return "Unknown"
    }
}
