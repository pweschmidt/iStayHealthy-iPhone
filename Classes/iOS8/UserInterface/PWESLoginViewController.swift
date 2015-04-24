//
//  PWESLoginViewController.swift
//  iStayHealthy
//
//  Created by Peter_Schmidt on 22/11/2014.
//
//

import UIKit
import MessageUI
import QuartzCore


class PWESLoginViewController: UIViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate
{
    var loginText:String?
    weak var loginHandler: PWESLoginHandler?
    @IBOutlet  var titleLabel: UILabel?
    @IBOutlet  var versionLabel: UILabel?
    @IBOutlet  var copyrightLabel: UILabel?
    @IBOutlet  var forgotButton: UIButton?
    @IBOutlet  var icon: UIImageView?
    @IBOutlet  var passwordField: UITextField?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        icon?.image = UIImage(named: "icon_50_flat")
        icon?.layer.cornerRadius = 10;
        icon?.layer.masksToBounds = true
        
        
        titleLabel?.font = UIFont(name: "HelveticaNeue-UltraLight", size: 45.0)
        versionLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 12.0)
        versionLabel?.text = versionString()
        copyrightLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 12.0)
        
        defaultTextFieldValues()
        
        forgotButton?.titleLabel?.text = NSLocalizedString("Forgot Password", tableName: nil, bundle: NSBundle.mainBundle(), value: "Forgot Password", comment: "Forgot Password")
        
        forgotButton?.titleLabel?.textColor = UIColor(red: 204.0 / 255.0, green: 0.0, blue: 0.0, alpha: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func versionString() -> String
    {
        let infoDictionary: NSDictionary = NSBundle.mainBundle().infoDictionary!
        var versionString: String? = infoDictionary.objectForKey("CFBundleShortVersionString") as? String
        
        if versionString == nil
        {
            versionString = "v4.1.0"
        }
        return versionString!
    }
    
    func defaultTextFieldValues()
    {
        passwordField?.text = NSLocalizedString("Enter password", tableName: nil, bundle: NSBundle.mainBundle(), value: "Enter password", comment: "Enter password")
        passwordField?.textColor = UIColor.darkGrayColor()
        passwordField?.secureTextEntry = false
        passwordField?.delegate = self
    }
    
    func login(password: String)
    {
        var isValidated: Bool = false
        var stringHash  = password.hash
        
        isValidated = KeychainHandler.compareKeychainValueForMatchingPIN(stringHash)
        if password == kSecretKey
        {
            isValidated = true
            let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(false, forKey: kIsPasswordEnabled)
            defaults.synchronize()
            defaultTextFieldValues()
            
            let alertTitle: String = NSLocalizedString("Password Reset", tableName: nil, bundle: NSBundle.mainBundle(), value: "Password Reset", comment: "Password Reset")
            let alertMessage: String = NSLocalizedString("Please reset password", tableName: nil, bundle: NSBundle.mainBundle(), value: "Please reset password", comment: "Please reset password")
            showAlert(alertTitle, message: alertMessage)
        }
        
        if !isValidated
        {
            let alertTitle: String = NSLocalizedString("Wrong Password", tableName: nil, bundle: NSBundle.mainBundle(), value: "Wrong Password", comment: "Wrong Password")
            let alertMessage: String = NSLocalizedString("Wrong Password! Try again", tableName: nil, bundle: NSBundle.mainBundle(), value: "Wrong Password! Try again", comment: "Wrong Password! Try again")
            showAlert(alertTitle, message: alertMessage)
            
        }
        else
        {
            if loginHandler != nil
            {
                loginHandler?.didLogin!()
            }
        }
    }
    
    
    func showAlert(title: String, message: String)
    {
        let alertView: UIAlertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK")
        alertView.show()
    }
    
    @IBAction func forgotButtonPressed(sender: UIButton)
    {
        if !MFMailComposeViewController.canSendMail()
        {
            return
        }
        var mailController:MFMailComposeViewController = MFMailComposeViewController()
        mailController.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        var recipients: NSArray = ["istayhealthy.app@gmail.com"]
        let subject: String = "I forgot my iStayHealthy password (iPhone)"
        mailController.mailComposeDelegate = self
        mailController.setToRecipients(recipients as [AnyObject])
        mailController.setSubject(subject)
        self.presentViewController(mailController, animated: true) { () -> Void in
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        textField.textColor = UIColor.blackColor()
        textField.secureTextEntry = true
    }

    func textFieldDidEndEditing(textField: UITextField)
    {
        var enteredPassword: String = textField.text
        println("entered password is \(enteredPassword)")
        self.login(enteredPassword)
        textField.resignFirstResponder()
    }

    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!)
    {
        controller.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
}
