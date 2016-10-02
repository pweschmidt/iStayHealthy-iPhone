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

    func resultsFromURLQueryString(_ queryString: String) -> NSDictionary
    {
        let queryComponents = queryString.components(separatedBy: "&")
        for component in queryComponents
        {
            let individualComponent = component.components(separatedBy: "=")
            if 2 == individualComponent.count
            {
                let mappedKeyString: String = mapResultsType(individualComponent[0])
                let valueString = individualComponent[1]
                //                println("key = \(mappedKeyString) and value = \(valueString)")
                resultsAttributeDictionary(mappedKeyString, valueString: valueString)
            }
        }
        return results
    }
    
    func resultsAttributeDictionary(_ keyString: String, valueString: String)
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
    
    func numberFromStringValue(_ keyString: String, valueString: String)
    {
        //        println("***** numberFromStringValue with key='\(keyString)' and value=\(valueString)")
        var value:NSNumber?
        if "undetectable" == valueString
        {
            value = NSNumber(value: 1 as Float)
            //            println("we have undetectable = \(value)")
            results.setObject(value!, forKey: keyString as NSCopying)
            return
        }

        let candidate: Float = (valueString as NSString).floatValue
        value = NSNumber(value: candidate as Float)
        if nil != value
        {
            //            println("added value \(value) to dictionary")
            results.setObject(value!, forKey: keyString as NSCopying)
        }
//        else
//        {
//            println("couldn't add valuestring to dictionary")
//        }
    }
    
    func dateFromStringValue(_ dateString: String)
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMMyyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let value: Date? = formatter.date(from: dateString)
        //        println("found date = \(value)")
        if nil != value
        {
            results.setObject(value!, forKey: kResultsDate as NSCopying)
        }
    }
    
    func bloodPressureFromString(_ bloodPressureString: String)
    {
        var components = bloodPressureString.components(separatedBy: "-")
        if 2 == components.count
        {
            let systoleString = components[0]
            let diastoleString = components[1]
            var systole:NSNumber?
            var diastole:NSNumber?
            var candidate: Float = (systoleString as NSString).floatValue
            systole = NSNumber(value: candidate as Float)
            candidate = (diastoleString as NSString).floatValue
            diastole = NSNumber(value: candidate as Float)
            
            if nil != systole && nil != diastole
            {
                results.setObject(systole!, forKey: kSystole as NSCopying)
                results.setObject(diastole!, forKey: kDiastole as NSCopying)
            }
        }
    }
    
    func addResultsData(_ keyString: String, value: AnyObject?)
    {
        results.setObject(value!, forKey: keyString as NSCopying)
    }
    
    func mapResultsType(_ type:String) -> String
    {
        if ComparisonResult.orderedSame == type.caseInsensitiveCompare(kCD4)
        {
            return kCD4;
        }
        else if ComparisonResult.orderedSame == type.caseInsensitiveCompare(kCD4Percent)
        {
            return kCD4Percent
        }
        else if ComparisonResult.orderedSame == type.caseInsensitiveCompare(kViralLoad)
        {
            return kViralLoad
        }
        else if ComparisonResult.orderedSame == type.caseInsensitiveCompare(kResultsDate) ||
       ComparisonResult.orderedSame == type.caseInsensitiveCompare("ResultDate") ||
        ComparisonResult.orderedSame == type.caseInsensitiveCompare("date")
        {
            return kResultsDate
        }
        else if ComparisonResult.orderedSame == type.caseInsensitiveCompare("BloodPressure")
        {
            return "BloodPressure"
        }
        else if ComparisonResult.orderedSame == type.caseInsensitiveCompare(kBMI)
        {
            return kBMI
        }
        else if ComparisonResult.orderedSame == type.caseInsensitiveCompare("CardiacRisk")
        {
            return kCardiacRiskFactor
        }
        else if ComparisonResult.orderedSame == type.caseInsensitiveCompare("Cholesterol")
        {
            return kTotalCholesterol
        }
        
        return "Unknown"
    }
}
