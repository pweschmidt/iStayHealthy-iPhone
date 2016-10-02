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
        
        forgotButton?.titleLabel?.text = NSLocalizedString("Forgot Password", tableName: nil, bundle: Bundle.main, value: "Forgot Password", comment: "Forgot Password")
        
        forgotButton?.titleLabel?.textColor = UIColor(red: 204.0 / 255.0, green: 0.0, blue: 0.0, alpha: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func versionString() -> String
    {
        let infoDictionary: NSDictionary = Bundle.main.infoDictionary! as NSDictionary
        var versionString: String? = infoDictionary.object(forKey: "CFBundleShortVersionString") as? String
        
        if versionString == nil
        {
            versionString = "v4.1.0"
        }
        return versionString!
    }
    
    func defaultTextFieldValues()
    {
        passwordField?.text = NSLocalizedString("Enter password", tableName: nil, bundle: Bundle.main, value: "Enter password", comment: "Enter password")
        passwordField?.textColor = UIColor.darkGray
        passwordField?.isSecureTextEntry = false
        passwordField?.delegate = self
    }
    
    func login(_ password: String)
    {
        var isValidated: Bool = false
        let stringHash  = password.hash
        
        isValidated = KeychainHandler.compareKeychainValueFor(matchingPIN: stringHash)
        if password == kSecretKey
        {
            isValidated = true
            let defaults: UserDefaults = UserDefaults.standard
            defaults.set(false, forKey: kIsPasswordEnabled)
            defaults.synchronize()
            defaultTextFieldValues()
            
            let alertTitle: String = NSLocalizedString("Password Reset", tableName: nil, bundle: Bundle.main, value: "Password Reset", comment: "Password Reset")
            let alertMessage: String = NSLocalizedString("Please reset password", tableName: nil, bundle: Bundle.main, value: "Please reset password", comment: "Please reset password")
            showAlert(alertTitle, message: alertMessage)
        }
        
        if !isValidated
        {
            let alertTitle: String = NSLocalizedString("Wrong Password", tableName: nil, bundle: Bundle.main, value: "Wrong Password", comment: "Wrong Password")
            let alertMessage: String = NSLocalizedString("Wrong Password! Try again", tableName: nil, bundle: Bundle.main, value: "Wrong Password! Try again", comment: "Wrong Password! Try again")
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
    
    
    func showAlert(_ title: String, message: String)
    {
        let alertView: UIAlertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK")
        alertView.show()
    }
    
    @IBAction func forgotButtonPressed(_ sender: UIButton)
    {
        if !MFMailComposeViewController.canSendMail()
        {
            return
        }
        let mailController:MFMailComposeViewController = MFMailComposeViewController()
        mailController.navigationController?.navigationBar.tintColor = UIColor.black
        let recipients: NSArray = ["istayhealthy.app@gmail.com"]
        let subject: String = "I forgot my iStayHealthy password (iPhone)"
        mailController.mailComposeDelegate = self
        mailController.setToRecipients(recipients as [AnyObject] as [AnyObject])
        mailController.setSubject(subject)
        self.present(mailController, animated: true) { () -> Void in
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        textField.textColor = UIColor.black
        textField.isSecureTextEntry = true
    }

    func textFieldDidEndEditing(_ textField: UITextField)
    {
        let enteredPassword: String = textField.text!
        //        println("entered password is \(enteredPassword)")
        self.login(enteredPassword)
        textField.resignFirstResponder()
    }

    func mailComposeController(_ controller: MFMailComposeViewController!, didFinishWith result: MFMailComposeResult, error: Error!)
    {
        controller.dismiss(animated: true, completion: { () -> Void in
        })
    }
}
