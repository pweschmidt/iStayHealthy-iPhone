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
    var customNavigationController: UINavigationController!
    var isCollapsed: Bool = true
    var menuController: HamburgerMenuTableViewController?
    var loginController_iPad: LoginViewController_iPad?
    var loginController: LoginViewController?
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        var dashboardController: PWESDashboardViewController = PWESDashboardViewController()
        dashboardController.menuHandler = self
        self.customNavigationController = UINavigationController(rootViewController: dashboardController)
        view.addSubview(self.customNavigationController.view)
        self.customNavigationController.didMoveToParentViewController(self)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func transitionToLoginController()
    {
        
    }
    

    func showMenuPanel()
    {
        if self.isCollapsed
        {
            if(menuController == nil)
            {
                menuController = HamburgerMenuTableViewController()
            }
            addMenuController(menuController!)
        }
        animateLeftPanel(shouldExpand: self.isCollapsed)
    }

    func dismissMenuPanel(controllerName: String)
    {
        animateLeftPanel(shouldExpand: false)
        replaceMainController(controllerName)
    }
    
    func addMenuController(menuController: HamburgerMenuTableViewController)
    {
        menuController.menuHandler = self
        view.insertSubview(menuController.view, atIndex: 0)
        addChildViewController(menuController)
        menuController.didMoveToParentViewController(self)
    }
    
    func replaceMainController(controllerName: String)
    {
        self.customNavigationController!.view.removeFromSuperview()
        self.customNavigationController = nil
        
        if self.traitCollection.horizontalSizeClass == .Regular
        {
            var navController: UINavigationController? = navigationControllerForiPad(controllerName)
            if navController == nil
            {
                return
            }
            self.customNavigationController = navController
            
            self.customNavigationController.view.frame.origin.x = customNavigationController.view.frame.origin.x + 180.0
            self.view.addSubview(self.customNavigationController.view)
            self.customNavigationController.didMoveToParentViewController(self)
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.isCollapsed = true
                
                if self.menuController != nil
                {
                    self.menuController!.view.removeFromSuperview()
                    self.menuController = nil;
                }
            }
        }
        else
        {
            var navController: UINavigationController? = navigationControllerForiPhone(controllerName)
            if navController == nil
            {
                return
            }
            self.customNavigationController = navController
            self.customNavigationController.view.transform = CGAffineTransformMakeScale(0.8, 0.8)
            self.customNavigationController.view.frame.origin.x = CGRectGetWidth(customNavigationController.view.frame) - 80
            self.view.addSubview(self.customNavigationController.view)
            self.customNavigationController.didMoveToParentViewController(self)
            zoomInMainController(targetPosition: 0) { finished in
                self.isCollapsed = true
                if self.menuController != nil
                {
                    self.menuController!.view.removeFromSuperview()
                    self.menuController = nil;
                }
            }
        }
        
    }
    
    
    
    func animateLeftPanel(#shouldExpand: Bool)
    {
        let isRegular : Bool = self.traitCollection.horizontalSizeClass == .Regular
        
        if (shouldExpand)
        {
            isCollapsed = false
            if isRegular
            {
                animateCenterPanelXPosition(targetPosition: customNavigationController.view.frame.origin.x + 180.0)
            }
            else
            {
                zoomOutMainController(targetPosition: CGRectGetWidth(customNavigationController.view.frame) - 80)
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
            self.customNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    
    func navigationControllerForiPad(controllerName: String) -> UINavigationController?
    {
        var navigationController: UINavigationController?
        if controllerName == kResultsController
        {
            var controller: ResultsCollectionViewController = ResultsCollectionViewController()
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kDashboardController
        {
            var controller: PWESDashboardViewController = PWESDashboardViewController()
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kDropboxController
        {
            var controller: DropboxViewController = DropboxViewController()
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kHIVMedsController
        {
            var controller: MyHIVCollectionViewController = MyHIVCollectionViewController()
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kOtherMedsController
        {
            var controller: OtherMedsCollectionViewController = OtherMedsCollectionViewController()
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kSideEffectsController
        {
            var controller: SideEffectsCollectionViewController = SideEffectsCollectionViewController()
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kMissedController
        {
            var controller: MissedMedicationCollectionViewController = MissedMedicationCollectionViewController()
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kMedicationDiaryController
        {
            var controller: PWESSeinfeldCollectionViewController = PWESSeinfeldCollectionViewController()
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kProceduresController
        {
            var controller: ProceduresCollectionViewController = ProceduresCollectionViewController()
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kClinicsController
        {
            var controller: ClinicAddressCollectionViewController = ClinicAddressCollectionViewController()
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kAlertsController
        {
            var controller: NotificationsAlertsCollectionViewController = NotificationsAlertsCollectionViewController()
            navigationController = UINavigationController(rootViewController: controller)
        }
        return navigationController
    }

    func navigationControllerForiPhone(controllerName: String) -> UINavigationController?
    {
        var navigationController: UINavigationController?
        if controllerName == kResultsController
        {
            var controller: ResultsCollectionViewController = ResultsCollectionViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kDashboardController
        {
            var controller: PWESDashboardViewController = PWESDashboardViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kDropboxController
        {
            var controller: DropboxViewController = DropboxViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kHIVMedsController
        {
            var controller: MyHIVCollectionViewController = MyHIVCollectionViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kOtherMedsController
        {
            var controller: OtherMedsCollectionViewController = OtherMedsCollectionViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kSideEffectsController
        {
            var controller: SideEffectsCollectionViewController = SideEffectsCollectionViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kMissedController
        {
            var controller: MissedMedicationCollectionViewController = MissedMedicationCollectionViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kMedicationDiaryController
        {
            var controller: PWESSeinfeldCollectionViewController = PWESSeinfeldCollectionViewController()
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kProceduresController
        {
            var controller: ProceduresCollectionViewController = ProceduresCollectionViewController()
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kClinicsController
        {
            var controller: ClinicAddressCollectionViewController = ClinicAddressCollectionViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kAlertsController
        {
            var controller: NotificationsAlertsCollectionViewController = NotificationsAlertsCollectionViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        return navigationController
    }
    
}
