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
            sendResults()
        }
    }
    
    func sendResults()
    {
        
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

}
