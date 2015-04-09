//
//  PWESDataImportViewController.swift
//  iStayHealthy
//
//  Created by Peter_Schmidt on 09/04/2015.
//
//

import UIKit

class PWESDataImportViewController: UITableViewController {

    var userDataNotification: NSNotification?
    let cellIdentifier = "ImportCellIdentifier"
    var dataCollection: NSDictionary?

    init(notification: NSNotification)
    {
        super.init(style: UITableViewStyle.Grouped)
        userDataNotification = notification
    }

    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("ImportData", tableName: nil, bundle: NSBundle.mainBundle(), value: "ImportData", comment: "")
        self.view.backgroundColor = kDefaultBackground
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        let saveButton = UIBarButtonItem(title: NSLocalizedString("Save", tableName: nil, bundle: NSBundle.mainBundle(), value: "Save", comment: ""), style: UIBarButtonItemStyle.Plain, target: self, action: "saveAll")
        self.navigationItem.rightBarButtonItem = saveButton
        importAll()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        var objectArray: NSArray?
        var count: Int?
        var text: String = ""
        switch(indexPath.row)
        {
        case 0:
            text += NSLocalizedString(kResults, tableName: nil, bundle: NSBundle.mainBundle(), value: kResults, comment: "")
            objectArray = dataCollection?.objectForKey(kResults) as? NSArray
            count = objectArray?.count
            break;
        case 1:
            objectArray = dataCollection?.objectForKey(kMedications) as? NSArray
            count = objectArray?.count
            break;
        case 2:
            objectArray = dataCollection?.objectForKey(kOtherMedications) as? NSArray
            count = objectArray?.count
            break;
        case 3:
            objectArray = dataCollection?.objectForKey(kIllnessAndProcedures) as? NSArray
            count = objectArray?.count
            break;
        case 4:
            objectArray = dataCollection?.objectForKey(kPreviousMedications) as? NSArray
            count = objectArray?.count
            break;
        case 5:
            objectArray = dataCollection?.objectForKey(kHIVSideEffects) as? NSArray
            count = objectArray?.count
            break;
        case 6:
            objectArray = dataCollection?.objectForKey(kClinicalContacts) as? NSArray
            count = objectArray?.count
            break;
        case 7:
            objectArray = dataCollection?.objectForKey(kMissedMedications) as? NSArray
            count = objectArray?.count
            break;
        default:
            break;
        }

        text += " \(count)"
        cell.textLabel?.textColor = kTextColour
        cell.textLabel?.text = text
        return cell
    }

    func saveAll()
    {
        if nil == dataCollection
        {
            return
        }
        let dbImporter = PWESCoreDictionaryImporter()
        var saveError: NSError?
        dbImporter.saveToCoreData(dataCollection!, error: &saveError)
    }
    
    
    func importAll()
    {
        if nil == userDataNotification
        {
            return
        }
        let notification = userDataNotification!
        let userInfo: Dictionary? = notification.userInfo
        if nil == userInfo
        {
            return
        }
        
        let url = userInfo![kURLFilePathKey] as! NSURL
        
        let importer = PWESCoreXMLImporter()
        importer.importWithURL(url, completionBlock: { (success, dictionary, error) -> Void in
            if success && nil != dictionary
            {
                self.dataCollection = dictionary
                self.tableView.reloadData()
            }
        })
    }
    
}
