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
    var deviceToken : Data
    
    class var sharedToken : TokenCertificate{
        struct Static
        {
            static let instance : TokenCertificate = TokenCertificate()
        }
        return Static.instance
    }

    override init()
    {
        deviceToken = Data()
        super.init()
    }
    
    
    func deviceTokenAsString() -> String
    {
        var string: String = ""
        if 0 == deviceToken.count
        {
            return "No Token available"
        }
        
        var byteArray = [UInt8](repeating: 0x0, count: deviceToken.count)
        
        (deviceToken as NSData).getBytes(&byteArray, length: deviceToken.count)
        
        for value in byteArray
        {
            string += NSString(format: "%2X", value) as String
        }
        
        return string
    }
        
}
