//
//  PWESDataImportViewController.swift
//  iStayHealthy
//
//  Created by Peter_Schmidt on 09/04/2015.
//
//

import UIKit

class PWESDataImportViewController: UITableViewController {

    var userDataNotification: Notification?
    let cellIdentifier = "ImportCellIdentifier"
    var dataCollection: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("ImportData", tableName: nil, bundle: Bundle.main, value: "ImportData", comment: "")
        self.view.backgroundColor = kDefaultBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        let saveButton = UIBarButtonItem(title: NSLocalizedString("Save", tableName: nil, bundle: Bundle.main, value: "Save", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(PWESDataImportViewController.saveAll))
        self.navigationItem.rightBarButtonItem = saveButton
        importAll()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) 
        var objectArray: NSArray?
        var count = 0
        var text: String = ""
        switch((indexPath as NSIndexPath).row)
        {
        case 0:
            text += NSLocalizedString(kResults, tableName: nil, bundle: Bundle.main, value: kResults, comment: "")
            objectArray = dataCollection?.object(forKey: kResults) as? NSArray
            break;
        case 1:
            text += NSLocalizedString(kMedication, tableName: nil, bundle: Bundle.main, value: kMedication, comment: "")
            objectArray = dataCollection?.object(forKey: kMedications) as? NSArray
            break;
        case 2:
            text += NSLocalizedString(kOtherMedication, tableName: nil, bundle: Bundle.main, value: kOtherMedication, comment: "")
            objectArray = dataCollection?.object(forKey: kOtherMedications) as? NSArray
            break;
        case 3:
            text += NSLocalizedString(kProcedures, tableName: nil, bundle: Bundle.main, value: kProcedures, comment: "")
            objectArray = dataCollection?.object(forKey: kIllnessAndProcedures) as? NSArray
            break;
        case 4:
            text += NSLocalizedString(kPreviousMedication, tableName: nil, bundle: Bundle.main, value: kPreviousMedication, comment: "")
            objectArray = dataCollection?.object(forKey: kPreviousMedications) as? NSArray
            break;
        case 5:
            text += NSLocalizedString(kSideEffects, tableName: nil, bundle: Bundle.main, value: kSideEffects, comment: "")
            objectArray = dataCollection?.object(forKey: kHIVSideEffects) as? NSArray
            break;
        case 6:
            text += NSLocalizedString(kContacts, tableName: nil, bundle: Bundle.main, value: kContacts, comment: "")
            objectArray = dataCollection?.object(forKey: kClinicalContacts) as? NSArray
            break;
        case 7:
            text += NSLocalizedString(kMissedMedication, tableName: nil, bundle: Bundle.main, value: kMissedMedication, comment: "")
            objectArray = dataCollection?.object(forKey: kMissedMedications) as? NSArray
            break;
        default:
            break;
        }
        
        if nil != objectArray
        {
            count = objectArray!.count
        }

        text += ": " + (NSString(format: "%d", count) as String) + " "
        text += NSLocalizedString("to import", tableName: nil, bundle: Bundle.main, value: "to import", comment: "")
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
        do {
            try dbImporter.saveToCoreData(dataCollection)
        }catch {
            
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    func importAll()
    {
        if nil == userDataNotification
        {
            return
        }
        let notification = userDataNotification!
        let userInfo: Dictionary? = (notification as NSNotification).userInfo
        if nil == userInfo
        {
            return
        }
        
        let url = userInfo![kURLFilePathKey] as! URL
        
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
