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
        else if "ResultsDate" == keyString
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
            results.setObject(value!, forKey: "ResultsDate")
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
                results.setObject(systole!, forKey: "Systole")
                results.setObject(diastole!, forKey: "Diastole")
            }
        }
    }
    
    func addResultsData(keyString: String, value: AnyObject?)
    {
        results.setObject(value!, forKey: keyString)
    }
    
    func mapResultsType(type:String) -> String
    {
        if NSComparisonResult.OrderedSame == type.caseInsensitiveCompare("CD4")
        {
            return "CD4";
        }
        else if NSComparisonResult.OrderedSame == type.caseInsensitiveCompare("CD4Percent")
        {
            return "CD4Percent"
        }
        else if NSComparisonResult.OrderedSame == type.caseInsensitiveCompare("ViralLoad")
        {
            return "ViralLoad"
        }
        else if NSComparisonResult.OrderedSame == type.caseInsensitiveCompare("ResultsDate") ||
       NSComparisonResult.OrderedSame == type.caseInsensitiveCompare("ResultDate") ||
        NSComparisonResult.OrderedSame == type.caseInsensitiveCompare("date")
        {
            return "ResultsDate"
        }
        else if NSComparisonResult.OrderedSame == type.caseInsensitiveCompare("BloodPressure")
        {
            return "BloodPressure"
        }
        else if NSComparisonResult.OrderedSame == type.caseInsensitiveCompare("BMI")
        {
            return "bmi"
        }
        else if NSComparisonResult.OrderedSame == type.caseInsensitiveCompare("CardiacRisk")
        {
            return "cardiacRiskFactor"
        }
        else if NSComparisonResult.OrderedSame == type.caseInsensitiveCompare("Cholesterol")
        {
            return "TotalCholesterol"
        }
        
        return "Unknown"
    }
}
