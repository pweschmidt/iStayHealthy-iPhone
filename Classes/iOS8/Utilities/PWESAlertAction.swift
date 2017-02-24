//
//  PWESAlertAction.swift
//  iStayHealthy
//
//  Created by Schmidt, Peter (ELS) on 28/10/2016.
//
//

import UIKit

class PWESAlertAction: NSObject {

    var message: String = ""
    var buttonTitle: String = ""
    var alertAction: PWESAlertClosure?
    var actionStyle: UIAlertActionStyle = UIAlertActionStyle.default
    
    init(alertButtonTitle: String, style: UIAlertActionStyle, action: PWESAlertClosure?) {
        super.init()
        buttonTitle = alertButtonTitle
        actionStyle = style
        alertAction = action
    }
    
    var uiAlertAction: UIAlertAction {
        let action = UIAlertAction(title: buttonTitle, style: actionStyle) { (action) -> Void in
            if let registeredAction = self.alertAction {
                registeredAction()
            }
        }
        return action
    }
}
