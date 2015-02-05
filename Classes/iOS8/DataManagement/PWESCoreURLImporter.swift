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
                resultsAttributeDictionary(mappedKeyString, valueString: valueString)
            }
        }
        return results
    }
    
    func resultsAttributeDictionary(keyString: String, valueString: String)
    {
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
        if "CD4" != keyString || "CD4Percent" != keyString || "ViralLoad" != keyString || "TotalCholesterol" != keyString || "cardiacRiskFactor" != keyString || "bmi" != keyString
        {
            return
        }
        var value:NSNumber?
        if "undetectable" == valueString
        {
            value = NSNumber(float: 1)
        }
        var candidate: Float = (valueString as NSString).floatValue
        value = NSNumber(float: candidate)
        if nil != value
        {
            results.setValue(value, forUndefinedKey: keyString)
        }
    }
    
    func dateFromStringValue(dateString: String)
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMMyyyy"
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        var value: NSDate? = formatter.dateFromString(dateString)
        if nil != value
        {
            results.setValue(value, forUndefinedKey: "ResultsDate")
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
                results.setValue(systole, forUndefinedKey: "Systole")
                results.setValue(diastole, forUndefinedKey: "Diastole")
            }
        }
    }
    
    func addResultsData(keyString: String, value: AnyObject?)
    {
        results.setValue(value, forUndefinedKey: keyString)
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
