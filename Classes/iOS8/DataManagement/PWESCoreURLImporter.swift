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
                
            }
        }
        return results
    }
    
    func resultsAttributeDictionary(keyString: String, valueString: String)
    {
        if "CD4" == keyString
        {
        }
        else if "CD4Percent" == keyString
        {
            
        }
        else if "ViralLoad" == keyString
        {
            
        }
        else if "ResultsDate" == keyString
        {
            
        }
        else if "BMI" == keyString
        {
            
        }
        else if "BloodPressure" == keyString
        {
            bloodPressureFromString(valueString)
        }
        else if "Cholesterol" == keyString
        {
            
        }
        else if "CardiacRisk" == keyString
        {
            
        }
    }
    
    func numberFromStringValue(valueString: String) -> NSNumber?
    {
        if "undetectable" == valueString
        {
            return NSNumber(float: 1)
        }
        var value:NSNumber?
        var candidate: Float = (valueString as NSString).floatValue
        value = NSNumber(float: candidate)
        return value
    }
    
    func dateFromStringValue(dateString: String) -> NSDate?
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMMyyyy"
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        var value: NSDate? = formatter.dateFromString(dateString)
        return value
    }
    
    func bloodPressureFromString(bloodPressureString: String)
    {
        var components = bloodPressureString.componentsSeparatedByString("-")
        if 2 == components.count
        {
            let systoleString = components[0]
            let diastoleString = components[1]
            var systole = numberFromStringValue(systoleString)
            var diastole = numberFromStringValue(diastoleString)
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
