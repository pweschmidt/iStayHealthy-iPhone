//
//  PWESAlertHandler.swift
//  iStayHealthy
//
//  Created by Schmidt, Peter (ELS) on 27/10/2016.
//
//

import UIKit


class PWESAlertHandler: NSObject {
    
    static let alertHandler = PWESAlertHandler()
    
    func showAlertViewWithOKButton(_ title: String, message: String, presentingController: UIViewController)
    {
        showSimpleAlertViewWithCancelButton("OK", title: title, message: message, presentingController: presentingController)
    }
    
    func showAlertViewWithCancelButton(_ title: String, message: String, presentingController: UIViewController)
    {
        showSimpleAlertViewWithCancelButton("Cancel", title: title, message: message, presentingController: presentingController)
    }
    
    func showSimpleAlertViewWithCancelButton(_ buttonTitle: String, title: String, message: String, presentingController: UIViewController)
    {
        let action = PWESAlertAction(alertButtonTitle: buttonTitle, style: .cancel, action: nil)
        let actions = [action]
        showAlertView(title, message: message, presentingController: presentingController, actions: actions)
    }
    
    func showAlertView(_ title: String, message: String, presentingController: UIViewController, actions: [PWESAlertAction]) {
        guard 0 < actions.count else {
            return
        }
        let controller = UIAlertController(title: title, message: message, preferredStyle:UIAlertControllerStyle.alert)
        for action in actions {
            let uiAction = action.uiAlertAction
            controller.addAction(uiAction)
        }
        presentingController.present(controller, animated: true, completion: nil)
    }
    
}
