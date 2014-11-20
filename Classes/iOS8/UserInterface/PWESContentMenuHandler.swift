//
//  PWESContentMenuHandler.swift
//  iStayHealthy
//
//  Created by Peter_Schmidt on 20/11/2014.
//
//

import Foundation
import UIKit

@objc
protocol PWESContentMenuHandler
{
    optional func showMenuPanel()
    optional func dismissMenuPanel(controllerName: String)
}
