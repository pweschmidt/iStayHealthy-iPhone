//
//  PWESContainerViewController.swift
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/10/2014.
//
//

import UIKit

class PWESContainerViewController: UIViewController, UISplitViewControllerDelegate
{

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSplitViewController()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    func splitViewController(splitViewController: UISplitViewController!, collapseSecondaryViewController secondaryViewController:UIViewController!, ontoPrimaryViewController primaryViewController:UIViewController!) -> Bool {
        return false
    }

    
    private func configureSplitViewController()
    {
        var splitController: PWESSplitViewController = PWESSplitViewController()
        splitController.delegate = self
        self.addChildViewController(splitController)
    }
    
}
