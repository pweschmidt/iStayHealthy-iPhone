//
//  PWESContentContainerController.swift
//  iStayHealthy
//
//  Created by Peter_Schmidt on 20/11/2014.
//
//

import UIKit

class PWESContentContainerController: UIViewController, PWESContentMenuHandler
{
    var isCollapsed: Bool = true
    var menuController: HamburgerMenuTableViewController?

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func showMenuPanel()
    {
        if isCollapsed
        {
            if(menuController == nil)
            {
                menuController = HamburgerMenuTableViewController()
            }
            addMenuController(menuController!)
        }
    }

    func dismissMenuPanel(controllerName: String)
    {
        animateLeftPanel(shouldExpand: false)
        replaceMainController(controllerName)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func replaceMainController(controllerName: String)
    {
//        self.customNavigationController!.view.removeFromSuperview()
//        self.customNavigationController = nil
//        if controllerName == "Charts"
//        {
//            let controller: ChartsViewController = chartsViewController!
//            controller.menuUpdater = self
//            self.customNavigationController = UINavigationController(rootViewController: controller)
//        }
//        else if controllerName == "Results"
//        {
//            let controller: ResultsTableViewController = ResultsTableViewController()
//            controller.menuUpdater = self
//            self.customNavigationController = UINavigationController(rootViewController: controller)
//        }
//        
//        if self.traitCollection.horizontalSizeClass == .Regular
//        {
//            self.customNavigationController.view.frame.origin.x = customNavigationController.view.frame.origin.x + 180.0
//            self.view.addSubview(self.customNavigationController.view)
//            self.customNavigationController.didMoveToParentViewController(self)
//            animateCenterPanelXPosition(targetPosition: 0) { finished in
//                self.isCollapsed = true
//                
//                if self.leftViewController != nil
//                {
//                    self.leftViewController!.view.removeFromSuperview()
//                    self.leftViewController = nil;
//                }
//            }
//        }
//        else
//        {
//            self.customNavigationController.view.transform = CGAffineTransformMakeScale(0.8, 0.8)
//            self.customNavigationController.view.frame.origin.x = CGRectGetWidth(customNavigationController.view.frame) - 80
//            self.view.addSubview(self.customNavigationController.view)
//            self.customNavigationController.didMoveToParentViewController(self)
//            zoomInMainController(targetPosition: 0) { finished in
//                self.isCollapsed = true
//                if self.leftViewController != nil
//                {
//                    self.leftViewController!.view.removeFromSuperview()
//                    self.leftViewController = nil;
//                }
//            }
//        }
//        
    }
    
    
    
    func animateLeftPanel(#shouldExpand: Bool)
    {
        let isRegular : Bool = self.traitCollection.horizontalSizeClass == .Regular
        
        if (shouldExpand)
        {
            isCollapsed = false
            if isRegular
            {
                //                animateCenterPanelXPosition(targetPosition: customNavigationController.view.frame.origin.x + 180.0)
            }
            else
            {
                //                zoomOutMainController(targetPosition: CGRectGetWidth(customNavigationController.view.frame) - 80)
            }
        }
        else
        {
            if isRegular
            {
                animateCenterPanelXPosition(targetPosition: 0) { finished in
                    self.isCollapsed = true
                    
                    self.menuController!.view.removeFromSuperview()
                    self.menuController = nil;
                }
            }
            else
            {
                zoomInMainController(targetPosition: 0) { finished in
                    self.isCollapsed = true
                    
                    self.menuController!.view.removeFromSuperview()
                    self.menuController = nil;
                }
            }
        }
    }
    
    func addMenuController(menuController: HamburgerMenuTableViewController)
    {
        //        menuController.menuUpdater = self;
        view.insertSubview(menuController.view, atIndex: 0)
        addChildViewController(menuController)
        menuController.didMoveToParentViewController(self)
    }
    
    
    /**
    ZOOM in/out methods
    */
    func zoomOutMainController(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil)
    {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
//            self.customNavigationController.view.transform = CGAffineTransformMakeScale(0.8, 0.8)
//            self.customNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
        
    }
    
    func zoomInMainController(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil)
    {
        var finalPosition: CGFloat = targetPosition
        if !isCollapsed
        {
            finalPosition = targetPosition + 40.0
        }
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            
//            self.customNavigationController.view.transform = CGAffineTransformIdentity
//            self.customNavigationController.view.frame.origin.x = self.view.frame.origin.x
            }, completion: completion)
    }
    
    /**
    sliding in/out
    */
    func animateCenterPanelXPosition(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil)
    {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            //            self.customNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    

}
