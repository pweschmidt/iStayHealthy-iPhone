//
//  DropboxSyncController.swift
//  iStayHealthy
//
//  Created by Schmidt, Peter (ELS) on 31/10/2016.
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "syncCell")
        view.backgroundColor = kDefaultBackground
        tableView.backgroundColor = kDefaultBackground
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
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
            cell.textLabel?.text = NSLocalizedString("Sync with Dropbox", comment: "")
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
                restore()
                backup()
            }
        }
        else {
            
        }
    }
    
    
    fileprivate func checkBackupAvailability(_ completionBlock: @escaping PWESSuccessClosure) {
        if let client = DropboxClientsManager.authorizedClient {
            client.files.search(path: "/", query: "iStayHealthy").response(completionHandler: { (searchResult, error) in
                if let result = searchResult {
                    if 0 == result.matches.count {
                        self.createiStayHealthyFolder({ (success, nsError) in
                            completionBlock(success, nsError)
                        })
                    }
                    else {
                        completionBlock(true, nil)
                    }
                }
                else if nil != error {
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
    
    
    fileprivate func backup() {
        let xmlWriter = CoreXMLWriter()
        xmlWriter.write { (xmlString, error) in
            if let xmlString = xmlString {
                if let data = xmlString.data(using: .utf8, allowLossyConversion: false) {
                    do {
                        try data.write(to: self.uploadPath)
                    }catch {
                        PWESAlertHandler.alertHandler.showAlertViewWithOKButton(NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Error writing data to tmp directory", comment: ""), presentingController: self)
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
        let destination: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
            return self.downloadPath
        }
        checkBackupAvailability { (success, error) in
            if success {
                
            }
            
        }
        
        
        if let client = DropboxClientsManager.authorizedClient {
            client.files.download(path: dropBoxBackupPath).response(completionHandler: { (response, error) in
                if let response = response {
                    
                }
                else if let error = error {
                    
                }
            }).progress({ (progressData) in
                _ = progressData.totalUnitCount
            })
        }
    }
    
    
    fileprivate func link() {
        DropboxClientsManager.authorizeFromController(UIApplication.shared, controller: self, openURL: {(url: URL) -> Void in UIApplication.shared.openURL(url)})
    }
    
    fileprivate func unlink() {
        DropboxClientsManager.unlinkClients()
    }
    
    
    

}
