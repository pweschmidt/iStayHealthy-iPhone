//
//  PWESPasswordStore.swift
//  iStayHealthy
//
//  Created by Peter Schmidt on 20/02/2015.
//
//

import UIKit

class PWESPasswordStore: NSObject
{
    func storePassword(password:String) -> Bool
    {
        return false
    }
    
    func removePassword() -> Bool
    {
        return false
    }
    
    func currentPassword() -> String
    {
        return ""
    }
    
    func passwordMatches(password: String) -> Bool
    {
        return false
    }
        
}
