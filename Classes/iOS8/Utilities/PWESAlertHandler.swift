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
        let cancelAction = UIAlertAction(title: buttonTitle, style: .cancel) { (action) in
        }
        
//        let cancelAction = MCAlertAction(actionTitle: buttonTitle, actionStyle: MCAlertActionStyle.cancel)
        let actions = [cancelAction]
        createAndDisplay(title, message: message, preferredStyle: .alert, actions: actions, presentingController: presentingController, barButtonItem: nil, sourceView: nil)
    }
    
    func createAndDisplay(_ title: String?, message: String?, preferredStyle: UIAlertControllerStyle, actions: [UIAlertAction]?, presentingController: UIViewController?, barButtonItem: UIBarButtonItem?, sourceView: UIView?)
    {
        let controller = UIAlertController(title: title, message: message, preferredStyle:preferredStyle)
        
        if nil == actions || 0 == actions!.count
        {
            return
        }
        else
        {
            for action in actions!
            {
                controller.addAction(action)
            }
        }
        if nil != presentingController
        {
            if (preferredStyle == UIAlertControllerStyle.actionSheet && (nil != barButtonItem || nil != sourceView))
            {
                controller.popoverPresentationController?.barButtonItem = barButtonItem;
                controller.popoverPresentationController?.sourceView = sourceView;
                //                if (nil != sourceView)
                //                {
                //                    controller.popoverPresentationController?.permittedArrowDirections = []
                //                }
            }
            presentingController!.present(controller, animated: true, completion: nil)
        }
    }

}
