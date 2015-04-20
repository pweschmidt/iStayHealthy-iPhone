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
    let changeiCloudOptions = [kOpenSettings,kOpeniCloud,kSelectiStayHealthy,kChangeSwitch]
    let disableiCloudOptions = [kOpenLocalBackup, kCheckiCloudEnabled]
    let recoverLocallyOptions = [kOpenLocalBackup, kSelectRecoverLocally]
    let dropboxOptions = [kSelectDropboxIcon, kSelectRestore]

    
    init(selectedHelpOption: UInt)
    {
        super.init(style: UITableViewStyle.Grouped)
        selectedOption = selectedHelpOption
    }

    required init!(coder aDecoder: NSCoder!)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }

}
