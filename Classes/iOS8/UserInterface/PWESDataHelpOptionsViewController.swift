//
//  PWESDataHelpOptionsViewController.swift
//  iStayHealthy
//
//  Created by Peter Schmidt on 15/04/2015.
//
//

import UIKit

class PWESDataHelpOptionsViewController: UIViewController
{
    var selectedOption: String = ""
    
    
    init(option: String)
    {
        super.init(nibName: nil, bundle: nil)
        selectedOption = option
    }
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let localizedString = NSLocalizedString(selectedOption, tableName: nil, bundle: NSBundle.mainBundle(), value: selectedOption, comment: "")
        self.navigationItem.title = localizedString
        self.view.backgroundColor = kDefaultBackground
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
