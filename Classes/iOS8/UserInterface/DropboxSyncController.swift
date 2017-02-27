//
//  DropboxSyncController.swift
//  iStayHealthy
//
//  Created by Schmidt, Peter (ELS) on 31/10/2016.
// Here is what the backup/restore process looks like
// Restore: probably the easiest
// 1.) download the iStayHealthy/iStayHealthy.isth file from Dropbox to the temp directory
// var downloadPath
// 2.) fire up CoreXMLReader, which reads the backup file and stores data in DB
// Backup:
// 1.) extract the DB data and store as tmp XML file (uploadPath)
// 2.) upload this fifle to a tmp file on Dropbox called toDropBox.xml (dropBoxUploadPath)
// 3.) rename (move) the existing iStayHealthy.isth on Dropbox to a file called iStayHealthyddMMMyyyy_HHmmss.isth 
// 4.) rename (move) the toDropBox.xml file to iStayHealthy.isth
//
// In each case
// check if we are authorised and also if the folder exists. Otherwise, create the iStayHealthy folder in root.
//
//

import UIKit
import SwiftyDropbox

class DropboxSyncController: UITableViewController {

    let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    let rootFolder = "/iStayHealthy"
    let backupRootName = "/iStayHealthy/iStayHealthy_"
    let backupFileExtension = ".isth"
    let dropBoxBackupPath = "/iStayHealthy/iStayHealthy.isth"
    let dropBoxUploadPath = "/iStayHealthy/toDropBox.xml"
    let dateFormatString = "ddMMMyyyy'_'HHmmss"

    var downloadPath: URL {
        get {
            return tmpURL.appendingPathComponent("fromDropBox.xml")
        }
    }

    var uploadPath: URL {
        get {
            return tmpURL.appendingPathComponent("toDropBox.xml")
        }
    }

    var backupFile: URL {
        get {
            return tmpURL.appendingPathComponent("iStayHealthy.isth")
        }
    }
    
    var revBackupFile: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateFormatString
            let formattedDateString = dateFormatter.string(from: Date())
            return "/iStayHealthy/iStayHealthy_"+formattedDateString+".isth"
        }
    }
    
    var backupAction: PWESAlertAction {
        get {
            let action = PWESAlertAction(alertButtonTitle: NSLocalizedString("Backup", comment: ""), style: .default) {
                self.backup()
            }
            return action
        }
    }
    
    var cancelAction: PWESAlertAction {
        get {
            let action = PWESAlertAction(alertButtonTitle: NSLocalizedString("Cancel", comment: ""), style: .cancel, action: nil)
            return action
        }
    }
    
    var restoreAction: PWESAlertAction {
        get{
            let action = PWESAlertAction(alertButtonTitle: NSLocalizedString("Restore", comment: ""), style: .default) {
                self.restore()
            }
            return action
        }
    }
    
    var linkAction: PWESAlertAction {
        get{
            let action = PWESAlertAction(alertButtonTitle: NSLocalizedString("Yes", comment: ""), style: .default) {
                self.link()
            }
            return action
        }
    }

    var unlinkAction: PWESAlertAction {
        get{
            let action = PWESAlertAction(alertButtonTitle: NSLocalizedString("Yes", comment: ""), style: .default) { self.unlink() }
            return action
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(DropboxSyncController.done))

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "syncCell")
        view.backgroundColor = kDefaultBackground
        tableView.backgroundColor = kDefaultBackground
    }
    
    func done () {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if 0 == section {
            return 2
        }
        else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "syncCell", for: indexPath)
        cell.contentView.backgroundColor = UIColor.white
        cell.textLabel?.textColor = kTextColour
        if 0 == indexPath.section {
            if nil != DropboxClientsManager.authorizedClient {
                cell.accessoryType = .disclosureIndicator
            }
            else {
                cell.textLabel?.textColor = UIColor.lightGray
            }
            if 0 == indexPath.row {
                cell.textLabel?.text = NSLocalizedString("Get from Dropbox", comment: "")
            }
            else {
                cell.textLabel?.text = NSLocalizedString("Save to Dropbox", comment: "")
            }
        }
        else {
            if nil != DropboxClientsManager.authorizedClient {
                cell.textLabel?.text = NSLocalizedString("Unlink Dropbox", comment: "")
            }
            else {
                cell.textLabel?.text = NSLocalizedString("Link with Dropbox", comment: "")
            }
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if 0 == indexPath.section {
            if nil != DropboxClientsManager.authorizedClient {
                if 0 == indexPath.row {
                    let actions = [restoreAction, cancelAction]
                    PWESAlertHandler.alertHandler.showAlertView(NSLocalizedString("Restore?", comment:""), message: NSLocalizedString("You are about to download  data from an external storage. Click Restore if you want to continue.", comment:""), presentingController: self, actions: actions)
                }
                else {
                    let actions = [backupAction, cancelAction]
                    PWESAlertHandler.alertHandler.showAlertView(NSLocalizedString("Backup?", comment:""), message: NSLocalizedString("You are about to store your data externally. Click Backup if you want to continue.", comment:""), presentingController: self, actions: actions)
                }
            }
        }
        else {
            if nil != DropboxClientsManager.authorizedClient {
                let actions = [unlinkAction, cancelAction]
                PWESAlertHandler.alertHandler.showAlertView(NSLocalizedString("Unlink?", comment:""), message: NSLocalizedString("Do you want to unlink your Dropbox account?", comment:""), presentingController: self, actions: actions)
            }
            else {
                let actions = [linkAction, cancelAction]
                PWESAlertHandler.alertHandler.showAlertView(NSLocalizedString("Link?", comment:""), message: NSLocalizedString("You are not linked to Dropbox account. Do you want to link it up now?", comment:""), presentingController: self, actions: actions)
            }
        }
    }
    
    
    
    
    fileprivate func backup() {
        let xmlWriter = CoreXMLWriter()
        xmlWriter.write { (xmlString, error) in
            if let xmlString = xmlString {
                if let data = xmlString.data(using: .utf8, allowLossyConversion: false) {
                    do {
                        try data.write(to: self.uploadPath)
                    }catch {
                        PWESAlertHandler.alertHandler.showAlertViewWithCancelButton(NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Error writing data to tmp directory", comment: ""), presentingController: self)
                    }
                    
                    self.checkBackupAvailability({ (success, error) in
                        if success {
                            self.uploadBackupFile(data, completionBlock: { (uploadSuccess, uploadError) in
                                if uploadSuccess {
                                   self.renameCurrentBackupFile({ (renameSuccess, renameError) in
                                    if renameSuccess {
                                        self.renameUploadedFile({ (finalSuccess, finalError) in
                                            if finalSuccess {
                                                PWESAlertHandler.alertHandler.showAlertViewWithOKButton(NSLocalizedString("Save Finished", comment: ""), message: NSLocalizedString("Data were sent to DropBox iStayHealthy.isth.", comment: ""), presentingController: self)
                                            }
                                            else {
                                                PWESAlertHandler.alertHandler.showAlertViewWithOKButton(NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Something went wrong when renaming the backup file.", comment: ""), presentingController: self)
                                            }
                                        })
                                    }
                                    else {
                                        PWESAlertHandler.alertHandler.showAlertViewWithOKButton(NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Something went wrong after uploading.", comment: ""), presentingController: self)
                                    }
                                   })
                                }
                                else {
                                    PWESAlertHandler.alertHandler.showAlertViewWithOKButton(NSLocalizedString("Error Uploading to Dropbox", comment: ""), message: NSLocalizedString("There was an error uploading data to Dropbox.", comment: ""), presentingController: self)
                                }
                            })
                        }
                        else {
                            PWESAlertHandler.alertHandler.showAlertViewWithOKButton(NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Could not access the backup folder.", comment: ""), presentingController: self)
                        }
                    })
                    
                    
                }
                
            }
            else if nil != error {
                PWESAlertHandler.alertHandler.showAlertViewWithOKButton(NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Could not create a valid backup file locally.", comment: ""), presentingController: self)
            }
        }
    }
    
    
    fileprivate func restore() {
        checkBackupAvailability { (success, error) in
            if success {
                self.downloadBackupFile({ (success, error) in
                    if success {
                        PWESAlertHandler.alertHandler.showAlertViewWithOKButton(NSLocalizedString("Restore Finished", comment: ""), message: NSLocalizedString("Data were retrieved from Dropbox.", comment: ""), presentingController: self)
                    }
                    else {
                        PWESAlertHandler.alertHandler.showAlertViewWithCancelButton(NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Error retrieving data.", comment: ""), presentingController: self)
                    }
                })
            }
            else {
                PWESAlertHandler.alertHandler.showAlertViewWithCancelButton(NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Error retrieving data.", comment: ""), presentingController: self)
            }
            
        }
    }
    
    
    fileprivate func link() {
        DropboxClientsManager.authorizeFromController(UIApplication.shared, controller: self, openURL: {(url: URL) -> Void in UIApplication.shared.openURL(url)})
    }
    
    fileprivate func unlink() {
        DropboxClientsManager.unlinkClients()
    }
    
    
    fileprivate func checkBackupAvailability(_ completionBlock: @escaping PWESSuccessClosure) {
        if let client = DropboxClientsManager.authorizedClient {
            client.files.search(path: "", query: "iStayHealthy").response(completionHandler: { (searchResult, error) in
                if let result = searchResult {
                    if 0 == result.matches.count {
                        print("no matches for folder found")
                        self.createiStayHealthyFolder({ (success, nsError) in
                            completionBlock(success, nsError)
                        })
                    }
                    else {
                        print("HURRAAAHHHH matches for folder found")
                        completionBlock(true, nil)
                    }
                }
                else if nil != error {
                    print("seems we got an error \(error)")
                    self.createiStayHealthyFolder({ (success, nsError) in
                        completionBlock(success, nsError)
                    })
                }
            })
        }
    }
    
    fileprivate func uploadBackupFile(_ data: Data, completionBlock: @escaping PWESSuccessClosure){
        if let client = DropboxClientsManager.authorizedClient {
            client.files.upload(path: self.dropBoxUploadPath, input: data).response(completionHandler: { (uploadResponse, error) in
                if nil != uploadResponse {
                    
                }
                else if nil != error {
                    completionBlock(false, nil)
                }
            })
        }
    }
    
    fileprivate func downloadBackupFile(_ completionBlock: @escaping PWESSuccessClosure) {
        let destination: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
            return self.downloadPath
        }
        if let client = DropboxClientsManager.authorizedClient {
            client.files.download(path: dropBoxBackupPath, destination: destination).response(completionHandler: { (response, error) in
                if nil != response {
                    do {
                        let downloadedData = try Data(contentsOf: self.downloadPath)
                        let reader = CoreXMLReader()
                        reader.parseXMLData(downloadedData, completionBlock: { (success, xmlError) in
                            completionBlock(true, nil)
                        })
                    } catch{
                        completionBlock(false, nil)
                    }
                    
                }
                else if nil != error {
                    completionBlock(false, nil)
                }
            })
        }
    }
    
    fileprivate func createiStayHealthyFolder(_ completionBlock: @escaping PWESSuccessClosure) {
        if let client = DropboxClientsManager.authorizedClient {
            client.files.createFolder(path: "/iStayHealthy").response(completionHandler: { (folderMetadata, error) in
                if nil != folderMetadata {
                    completionBlock(true, nil)
                }
                else if nil != error {
                    completionBlock(false, nil)
                }
            })
        }
    }
    
    fileprivate func renameCurrentBackupFile(_ completionBlock: @escaping PWESSuccessClosure) {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormatString
        let dateString = formatter.string(from: Date())
        let movedFilenamePath = backupRootName + dateString + backupFileExtension
        if let client = DropboxClientsManager.authorizedClient {
            client.files.move(fromPath: dropBoxBackupPath, toPath: movedFilenamePath).response(completionHandler: { (response, error) in
                if nil != response {
                    self.renameUploadedFile(completionBlock)
                }
                else if nil != error {
                    completionBlock(false, nil)
                }
            })
        }
    }
    
    fileprivate func renameUploadedFile(_ completionBlock: @escaping PWESSuccessClosure) {
        if let client = DropboxClientsManager.authorizedClient {
            client.files.move(fromPath: dropBoxUploadPath, toPath: dropBoxBackupPath).response(completionHandler: { (response, error) in
                if nil != response {
                    completionBlock(true, nil)
                }
                else if nil != error {
                    completionBlock(false, nil)
                }
            })
        }
    }
    
    
    
}
