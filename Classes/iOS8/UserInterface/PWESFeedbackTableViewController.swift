//
//  PWESFeedbackTableViewController.swift
//  iStayHealthy
//
//  Created by Peter Schmidt on 24/02/2015.
//
//

import UIKit
import MessageUI

class PWESFeedbackTableViewController: UITableViewController, MFMailComposeViewControllerDelegate, UIAlertViewDelegate
{

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.backgroundColor = kDefaultBackground
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MailCell")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }


    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if 0 == indexPath.section
        {
            sendFeedback()
        }
        else
        {
            let manager = PWESPersistentStoreManager.defaultManager
            if manager.hasBackupFile()
            {
                let title = NSLocalizedString("Send data?", tableName: nil, bundle: NSBundle.mainBundle(), value: "Send data?", comment: "")
                let message = NSLocalizedString("You are about to email data. Click Yes if you want to continue.", tableName: nil, bundle: NSBundle.mainBundle(), value: "You are about to email data. Click Yes if you want to continue.", comment: "")
                let cancel = NSLocalizedString("Cancel", tableName: nil, bundle: NSBundle.mainBundle(), value: "Cancel", comment: "")
                let yes = NSLocalizedString("Yes", tableName: nil, bundle: NSBundle.mainBundle(), value: "Yes", comment: "")
                let alert = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: cancel, otherButtonTitles: yes)
                alert.show()
            }
            else
            {
                let alert = UIAlertView()
                let title = NSLocalizedString("No data to send", tableName: nil, bundle: NSBundle.mainBundle(), value: "No data to send", comment: "")
                let message = NSLocalizedString("There are no backed up data to send", tableName: nil, bundle: NSBundle.mainBundle(), value: "There are no backed up data to send", comment: "")
                alert.title = title
                alert.message = message
                alert.show()
            }
        }
    }
    
    func sendResults()
    {
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = self
        controller.setToRecipients(["istayhealthy.app@gmail.com"])
        controller.setSubject("Results for iStayHealthy iPhone app")
        let manager = PWESPersistentStoreManager.defaultManager
        var data:NSData? = nil
        var path = manager.getBackupFilePath()
        var canSend = false
        if nil != path
        {
            data = manager.getDataFromPath(path)
            if nil != data
            {
                controller.addAttachmentData(data!, mimeType: "application/xml", fileName: "iStayHealthy.isth")
                canSend = true
            }
        }
        
        
        if MFMailComposeViewController.canSendMail() && canSend
        {
            var navigationController = self.parentViewController
            navigationController?.presentViewController(controller, animated: true, completion: { () -> Void in
            })
            
        }
        
    }
    
    func sendFeedback()
    {
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = self
        controller.setToRecipients(["istayhealthy.app@gmail.com"])
        controller.setSubject("Feedback for iStayHealthy iPhone app")
        
        if MFMailComposeViewController.canSendMail()
        {
            var navigationController = self.parentViewController
            navigationController?.presentViewController(controller, animated: true, completion: { () -> Void in
            })
            
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!)
    {
        controller.dismissViewControllerAnimated(true) { () -> Void in
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MailCell", forIndexPath: indexPath) as! UITableViewCell
        if 0 == indexPath.section
        {
            cell.textLabel?.text = NSLocalizedString("Feedback",  comment: "Feedback")
        }
        else
        {
            cell.textLabel?.text = NSLocalizedString("Email results",  comment: "Feedback")
        }
        return cell
    }

    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int)
    {
        let yes = NSLocalizedString("Yes", tableName: nil, bundle: NSBundle.mainBundle(), value: "Yes", comment: "")
        let title = alertView.buttonTitleAtIndex(buttonIndex)
        if title == yes
        {
            sendResults()
        }
    }
    
}
