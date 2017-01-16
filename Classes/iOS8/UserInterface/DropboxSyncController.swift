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
            client.files.listFolder(path: rootFolder).response(completionHandler: { (folderResults, error) in
                if nil != folderResults {
                    completionBlock(true, nil)
                }
                else if let error = error {
                    
                }
            })
        }
    }
    
    fileprivate func uploadBackupFile(_ data: Data, completionBlock: @escaping PWESSuccessClosure){
        if let client = DropboxClientsManager.authorizedClient {
            client.files.upload(path: self.dropBoxUploadPath, input: data).response(completionHandler: { (uploadResponse, error) in
                if nil != uploadResponse {
                    
                }
                else if let error = error {
                    
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
                else if let error = error {
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
                    if let client = DropboxClientsManager.authorizedClient {
                        client.files.upload(path: self.dropBoxUploadPath, input: data).response(completionHandler: { (uploadResponse, uploadError) in
                            if nil != uploadResponse {
                                self.moveUploadedFiles()
                            }
                            else if nil != uploadError {
                                PWESAlertHandler.alertHandler.showAlertViewWithOKButton(NSLocalizedString("Error Uploading to Dropbox", comment: ""), message: NSLocalizedString("There was an error uploading data to Dropbox.", comment: ""), presentingController: self)
                                
                            }
                        })
                    }
                }
                
            }
            else if let error = error {
                PWESAlertHandler.alertHandler.showAlertViewWithOKButton(NSLocalizedString("Error", comment: ""), message: NSLocalizedString(error.localizedDescription, comment: ""), presentingController: self)
            }
        }
    }
    
    fileprivate func moveUploadedFiles() {
        if let client = DropboxClientsManager.authorizedClient {
            client.files.search(path: "/iStayHealthy", query: "iStayHealthy.isth").response(completionHandler: { (searchResults, error) in
                if let searchResults = searchResults {
                    if searchResults.matches.count > 0 {
                        client.files.move(fromPath: self.dropBoxBackupPath, toPath: self.revBackupFile).response(completionHandler: { (response, moveError) in
                            self.moveUploadedFile()
                        })
                    }
                }
                else if nil != error {
                    
                }
                else {
                    self.moveUploadedFile()
                }
            })
        }
    }
    
    fileprivate func moveUploadedFile() {
        if let client = DropboxClientsManager.authorizedClient {
            client.files.move(fromPath: dropBoxUploadPath, toPath: dropBoxBackupPath).response(completionHandler: { (response, error) in
                if nil != response {
                    
                }
                else if nil != error {
                    
                }
            })
        }
    }
    
    fileprivate func restore() {
        let destination: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
            return self.downloadPath
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
