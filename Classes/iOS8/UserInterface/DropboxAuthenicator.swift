//
//  DropboxAuthenicator.swift
//  iStayHealthy
//
//  Created by Schmidt, Peter (ELS) on 02/02/2017.
//
//

import UIKit
import SwiftyDropbox

class DropboxAuthenicator: NSObject {
    static let authenticator = DropboxAuthenicator()

    
    func launchDropboxController(_ parentController: UIViewController, barButton: UIBarButtonItem) {
        if DropboxClientsManager.authorizedClient != nil{
            let dropboxController = DropboxSyncController(style: .grouped)
            let navController = UINavigationController(rootViewController: dropboxController)
            navController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popController = navController.popoverPresentationController
            popController?.permittedArrowDirections = .any
            popController?.barButtonItem = barButton
            parentController.present(navController, animated: true, completion: nil)
        }
        else {
            DropboxClientsManager.authorizeFromController(UIApplication.shared, controller: parentController, openURL: { (url) in
                UIApplication.shared.openURL(url)
            })
        }
    }
    
}
