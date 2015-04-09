//
//  TokenCertificate.swift
//  iStayHealthy
//
//  Created by Peter_Schmidt on 01/11/2014.
//
//

import Foundation
import UIKit

class TokenCertificate: NSObject
{
    var deviceToken : NSData
    
    class var sharedToken : TokenCertificate{
        struct Static
        {
            static let instance : TokenCertificate = TokenCertificate()
        }
        return Static.instance
    }

    override init()
    {
        deviceToken = NSData()
        super.init()
    }
    
    
    func deviceTokenAsString() -> String
    {
        var string: String = ""
        if 0 == deviceToken.length
        {
            return "No Token available"
        }
        
        var byteArray = [UInt8](count: deviceToken.length, repeatedValue: 0x0)
        
        deviceToken.getBytes(&byteArray, length: deviceToken.length)
        
        for value in byteArray
        {
            string += NSString(format: "%2X", value) as String
        }
        
        return string
    }
        
}
