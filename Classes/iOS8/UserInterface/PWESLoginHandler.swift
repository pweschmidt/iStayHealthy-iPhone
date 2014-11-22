//
//  PWESLoginHandler.swift
//  iStayHealthy
//
//  Created by Peter_Schmidt on 22/11/2014.
//
//

import Foundation
import UIKit

@objc
protocol PWESLoginHandler
{
    optional func didLogin()
    optional func didLoginFailed()
}
