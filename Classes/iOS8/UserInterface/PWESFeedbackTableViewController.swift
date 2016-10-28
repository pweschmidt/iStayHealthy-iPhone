//
//  PWESFeedbackTableViewController.swift
//  iStayHealthy
//
//  Created by Peter Schmidt on 24/02/2015.
//
//

import UIKit
import MessageUI

class PWESFeedbackTableViewController: UITableViewController, MFMailComposeViewControllerDelegate
{
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Feedback", tableName: nil, bundle: Bundle.main, value: "Feedback", comment: "")
        self.tableView.backgroundColor = kDefaultBackground
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MailCell")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(PWESFeedbackTableViewController.done))
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    func done() {
        dismiss(animated: true)
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if 0 == (indexPath as NSIndexPath).section
        {
            sendFeedback()
        }
        else
        {
            let manager = PWESPersistentStoreManager.defaultManager
            if manager.hasBackupFile()
            {
                let title = NSLocalizedString("Send data?", tableName: nil, bundle: Bundle.main, value: "Send data?", comment: "")
                let message = NSLocalizedString("You are about to email data. Click Yes if you want to continue.", tableName: nil, bundle: Bundle.main, value: "You are about to email data. Click Yes if you want to continue.", comment: "")
                let cancel = NSLocalizedString("Cancel", tableName: nil, bundle: Bundle.main, value: "Cancel", comment: "")
                let yes = NSLocalizedString("Yes", tableName: nil, bundle: Bundle.main, value: "Yes", comment: "")
                
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: cancel, style: .cancel, handler: nil)
                let yesAction = UIAlertAction(title: yes, style: .default, handler: { (action) -> Void in
                    self.sendResults()})
                
                alertController.addAction(cancelAction)
                alertController.addAction(yesAction)
                self.present(alertController, animated: true, completion: { () -> Void in
                })
            }
            else
            {
                let title = NSLocalizedString("No data to send", tableName: nil, bundle: Bundle.main, value: "No data to send", comment: "")
                let message = NSLocalizedString("There are no backed up data to send", tableName: nil, bundle: Bundle.main, value: "There are no backed up data to send", comment: "")
                let cancel = NSLocalizedString("Ok", tableName: nil, bundle: Bundle.main, value: "Ok", comment: "")
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: cancel, style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: { () -> Void in
                })
            }
        }
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) { () -> Void in
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func sendResults()
    {
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = self
        controller.setSubject("Results for iStayHealthy iPhone app")
        let manager = PWESPersistentStoreManager.defaultManager
        var data:Data? = nil
        let path = manager.getBackupFilePath()
        var canSend = false
        if nil != path
        {
            data = manager.getDataFromPath(path)
            if nil != data
            {
                controller.addAttachmentData(data!, mimeType: "application/istayhealthy", fileName: "iStayHealthy.isth")
                canSend = true
            }
        }
        
        
        if MFMailComposeViewController.canSendMail() && canSend
        {
            let navigationController = self.parent
            navigationController?.present(controller, animated: true, completion: { () -> Void in
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
            let navigationController = self.parent
            navigationController?.present(controller, animated: true, completion: { () -> Void in
            })
            
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.dismiss(animated: true) { () -> Void in
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MailCell", for: indexPath) 
        if 0 == (indexPath as NSIndexPath).section
        {
            cell.textLabel?.text = NSLocalizedString("Feedback",  comment: "Feedback")
            cell.textLabel?.textColor = kTextColour
        }
        else
        {
            cell.textLabel?.text = NSLocalizedString("Email results",  comment: "Feedback")
        }
        cell.textLabel?.textColor = kTextColour
        cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        return cell
    }
    
}
