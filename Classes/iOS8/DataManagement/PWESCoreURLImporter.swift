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
                var keyString = individualComponent[0]
                var valueString = individualComponent[1]
                resultsAttributeDictionary(keyString, valueString: valueString)
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
        if "CD4" != keyString || "CD4Percent" != keyString || "ViralLoad" != keyString || "Cholesterol" != keyString || "CardiacRisk" != keyString || "BMI" != keyString
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
}
