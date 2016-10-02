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
    @objc optional func showMenuPanel()
    @objc optional func dismissMenuPanel(_ controllerName: String?)
}
