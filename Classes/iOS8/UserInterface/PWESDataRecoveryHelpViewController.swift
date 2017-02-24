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
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.navigationItem.title = NSLocalizedString(kManageDataOptions, tableName: nil, bundle: Bundle.main, value: kManageDataOptions, comment: "")
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return options.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) 

        let text: String = options[(indexPath as NSIndexPath).row]
        let localizedString = NSLocalizedString(text, tableName: nil, bundle: Bundle.main, value: text, comment: "")
        cell.textLabel?.text = localizedString
        cell.textLabel?.textColor = kTextColour
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
//        let text: String = options[(indexPath as NSIndexPath).row]
        let index: UInt = UInt((indexPath as NSIndexPath).row)
        let helpViewer = PWESDataRecoveryStepsTableViewController(style: UITableViewStyle.grouped)
        helpViewer.selectedOption = index
        self.navigationController?.pushViewController(helpViewer, animated: true)
    }

}
