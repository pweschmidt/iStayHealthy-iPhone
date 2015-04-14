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
        var count: Int? = 0
        var text: String = ""
        switch(indexPath.row)
        {
        case 0:
            text += NSLocalizedString(kResults, tableName: nil, bundle: NSBundle.mainBundle(), value: kResults, comment: "")
            objectArray = dataCollection?.objectForKey(kResults) as? NSArray
            count = objectArray?.count
            break;
        case 1:
            text += NSLocalizedString(kMedication, tableName: nil, bundle: NSBundle.mainBundle(), value: kMedication, comment: "")
            objectArray = dataCollection?.objectForKey(kMedications) as? NSArray
            count = objectArray?.count
            break;
        case 2:
            text += NSLocalizedString(kOtherMedication, tableName: nil, bundle: NSBundle.mainBundle(), value: kOtherMedication, comment: "")
            objectArray = dataCollection?.objectForKey(kOtherMedications) as? NSArray
            count = objectArray?.count
            break;
        case 3:
            text += NSLocalizedString(kProcedures, tableName: nil, bundle: NSBundle.mainBundle(), value: kProcedures, comment: "")
            objectArray = dataCollection?.objectForKey(kIllnessAndProcedures) as? NSArray
            count = objectArray?.count
            break;
        case 4:
            text += NSLocalizedString(kPreviousMedication, tableName: nil, bundle: NSBundle.mainBundle(), value: kPreviousMedication, comment: "")
            objectArray = dataCollection?.objectForKey(kPreviousMedications) as? NSArray
            count = objectArray?.count
            break;
        case 5:
            text += NSLocalizedString(kSideEffects, tableName: nil, bundle: NSBundle.mainBundle(), value: kSideEffects, comment: "")
            objectArray = dataCollection?.objectForKey(kHIVSideEffects) as? NSArray
            count = objectArray?.count
            break;
        case 6:
            text += NSLocalizedString(kContacts, tableName: nil, bundle: NSBundle.mainBundle(), value: kContacts, comment: "")
            objectArray = dataCollection?.objectForKey(kClinicalContacts) as? NSArray
            count = objectArray?.count
            break;
        case 7:
            text += NSLocalizedString(kMissedMedication, tableName: nil, bundle: NSBundle.mainBundle(), value: kMissedMedication, comment: "")
            objectArray = dataCollection?.objectForKey(kMissedMedications) as? NSArray
            count = objectArray?.count
            break;
        default:
            break;
        }
        if nil == count
        {
            count = 0
        }

        text += ": \(count)"
        text += NSLocalizedString("to import", tableName: nil, bundle: NSBundle.mainBundle(), value: "to import", comment: "")
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
        self.navigationController?.popViewControllerAnimated(true)
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
