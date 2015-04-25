//
//  PWESDataRecoveryStepsTableViewController.swift
//  iStayHealthy
//
//  Created by Peter Schmidt on 16/04/2015.
//
//

import UIKit

class PWESDataRecoveryStepsTableViewController: UITableViewController {

    var selectedOption: UInt = 0
    var selectedTitle: String = kChangeiCloud
    let cellIdentifier = "HelpStepCellIdentifier"
    let changeiCloudOptions = [kOpenSettings,kOpeniCloud,kSelectiStayHealthy,kChangeSwitch, kRestartApp]
    let disableiCloudOptions = [kOpenLocalBackup, kCheckiCloudEnabled]
    let recoverLocallyOptions = [kOpenLocalBackup, kSelectRecoverLocally]
    let dropboxOptions = [kSelectDropboxIcon, kSelectRestore]

        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString(selectedTitle, tableName: nil, bundle: NSBundle.mainBundle(), value: selectedTitle, comment: "")
        self.view.backgroundColor = kDefaultBackground
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        switch selectedOption
        {
        case 0:
            rows = changeiCloudOptions.count
        case 1:
            rows = disableiCloudOptions.count
        case 2:
            rows = recoverLocallyOptions.count
        case 3:
            rows = dropboxOptions.count
        default:
            rows = 0
        }
        return rows
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell

        var currentOption: String? = nil
        switch selectedOption
        {
        case 0:
            currentOption = changeiCloudOptions[indexPath.row]
        case 1:
            if 0 == indexPath.row
            {
                cell.imageView?.image = UIImage(named: "settings.png")
            }
            currentOption = disableiCloudOptions[indexPath.row]
        case 2:
            if 0 == indexPath.row
            {
                cell.imageView?.image = UIImage(named: "settings.png")
            }
            currentOption = recoverLocallyOptions[indexPath.row]
        case 3:
            if 0 == indexPath.row
            {
                cell.imageView?.image = UIImage(named: "dropbox.png")
            }
            currentOption = dropboxOptions[indexPath.row]
        default:
            currentOption = nil
        }
        if nil != currentOption
        {
            var localizedText = NSLocalizedString(currentOption!, tableName: nil, bundle: NSBundle.mainBundle(), value: currentOption!, comment: "")
            cell.textLabel?.text = localizedText
            cell.textLabel?.textColor = kTextColour
            cell.textLabel?.font = UIFont.systemFontOfSize(15)
        }

        return cell
    }

}
