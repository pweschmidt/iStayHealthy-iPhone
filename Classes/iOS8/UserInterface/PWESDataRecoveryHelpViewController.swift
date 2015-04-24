//
//  PWESDataRecoveryHelpViewController.swift
//  iStayHealthy
//
//  Created by Peter Schmidt on 15/04/2015.
//
//

import UIKit

class PWESDataRecoveryHelpViewController: UITableViewController
{
    let cellIdentifier = "DataCellIdentifier"
    let options = [kChangeiCloud, kDisable_iCloud, kRecoverLocally, kRecoverDropbox];

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.backgroundColor = kDefaultBackground
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.navigationItem.title = NSLocalizedString(kManageDataOptions, tableName: nil, bundle: NSBundle.mainBundle(), value: kManageDataOptions, comment: "")
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return options.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell

        let text: String = options[indexPath.row]
        let localizedString = NSLocalizedString(text, tableName: nil, bundle: NSBundle.mainBundle(), value: text, comment: "")
        cell.textLabel?.text = localizedString
        cell.textLabel?.textColor = kTextColour
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let text: String = options[indexPath.row]
        let index: UInt = UInt(indexPath.row)
        let helpViewer = PWESDataRecoveryStepsTableViewController(style: UITableViewStyle.Grouped)
        helpViewer.selectedOption = index
        self.navigationController?.pushViewController(helpViewer, animated: true)
    }

}
