//
//  PWESTransferDBViewController.swift
//  iStayHealthy
//
//  Created by Peter_Schmidt on 09/04/2015.
//
//

import UIKit

class PWESTransferDBViewController: UIViewController {

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = kDefaultBackground
        self.navigationItem.title = NSLocalizedString("DisableiCloud", tableName: nil, bundle: NSBundle.mainBundle(), value: "DisableiCloud", comment: "")
        
        let barButton = UIBarButtonItem(title: NSLocalizedString("Proceed", tableName: nil, bundle: NSBundle.mainBundle(), value: "Proceed", comment: ""), style: UIBarButtonItemStyle.Plain, target: self, action: "transferDataFromiCloud")
        
        self.navigationItem.rightBarButtonItem = barButton
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func transferDataFromiCloud()
    {
        let manager = PWESPersistentStoreManager.defaultManager
        var error: NSError?
        var success = manager.disableiCloudStore(&error)
        if success
        {
            showStartLabel()
            success = manager.configureStoreManager()
            if success
            {
                showSetUpLabel()
                manager.setUpNewStore()
                let hasBackupFile = manager.hasBackupFile()
                if hasBackupFile
                {
                    manager.loadDataFromBackupFile({ (success, error) -> Void in
                        if success
                        {
                            self.dataTransferred()
                            self.navigationController?.popToRootViewControllerAnimated(true)
                        }
                        else
                        {
                            self.dataTransferredFailed()
                        }
                    })
                }
                else
                {
                    dataTransferred()
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
            }
            else
            {
                showSetUpErrorLabel()
            }
        }
        else
        {
            showStartErrorLabel()
        }
    }
    
    func showStartLabel()
    {
        let label = UILabel.standardLabel()
        label.frame = CGRectMake(20.0, 50.0, self.view.frame.size.width - 40.0, 20.0)
        label.text = NSLocalizedString("iCloudDisabled", tableName: nil, bundle: NSBundle.mainBundle(), value: "iCloudDisabled", comment: "iCloudDisabled")
        label.textColor = kDarkGreen
        self.view.addSubview(label)
    }
    
    func showStartErrorLabel()
    {
        let label = UILabel.standardLabel()
        label.frame = CGRectMake(20.0, 50.0, self.view.frame.size.width - 40.0, 20.0)
        label.text = NSLocalizedString("iCloudDisabledFailed", tableName: nil, bundle: NSBundle.mainBundle(), value: "iCloudDisabledFailed", comment: "iCloudDisabledFailed")
        label.textColor = kDarkRed
        self.view.addSubview(label)
    }

    func showSetUpLabel()
    {
        let label = UILabel.standardLabel()
        label.frame = CGRectMake(20.0, 100.0, self.view.frame.size.width - 40.0,20.0)
        label.text = NSLocalizedString("StoreInitialised", tableName: nil, bundle: NSBundle.mainBundle(), value: "StoreInitialised", comment: "StoreInitialised")
        label.textColor = kDarkGreen
        self.view.addSubview(label)
    }

    func showSetUpErrorLabel()
    {
        let label = UILabel.standardLabel()
        label.frame = CGRectMake(20.0, 50.0, self.view.frame.size.width - 40.0, 20.0)
        label.text = NSLocalizedString("StoreInitialisedFailed", tableName: nil, bundle: NSBundle.mainBundle(), value: "StoreInitialisedFailed", comment: "StoreInitialised")
        label.textColor = kDarkRed
        self.view.addSubview(label)
    }
    func dataTransferred()
    {
        let title = NSLocalizedString("TransferSucceeded", tableName: nil, bundle: NSBundle.mainBundle(), value: "TransferSucceeded", comment: "")
        let message = NSLocalizedString("TransferSucceededMessage", tableName: nil, bundle: NSBundle.mainBundle(), value: "TransferSucceededMessage", comment: "")
        let cancel = NSLocalizedString("Cancel", tableName: nil, bundle: NSBundle.mainBundle(), value: "Cancel", comment: "")
   
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: cancel)
        alert.show()
    }

    func dataTransferredFailed()
    {
        let title = NSLocalizedString("TransferFailed", tableName: nil, bundle: NSBundle.mainBundle(), value: "TransferFailed", comment: "")
        let message = NSLocalizedString("TransferFailedMessage", tableName: nil, bundle: NSBundle.mainBundle(), value: "TransferFailedMessage", comment: "")
        let cancel = NSLocalizedString("Cancel", tableName: nil, bundle: NSBundle.mainBundle(), value: "Cancel", comment: "")
        
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: cancel)
        alert.show()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
