//
//  PWESContentContainerController.swift
//  iStayHealthy
//
//  Created by Peter_Schmidt on 20/11/2014.
//
//

import UIKit

class PWESContentContainerController: UIViewController, PWESContentMenuHandler, PWESLoginHandler
{
    var customNavigationController: UINavigationController?
    var isCollapsed: Bool = true
    var menuController: HamburgerMenuTableViewController?
    var defaultLoginController: PWESLoginViewController?
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.435294, green: 0.443137, blue: 0.47451, alpha: 1.0)
        let settings: AppSettings = AppSettings()
        if settings.hasPasswordEnabled()
        {
            loadLoginController()
        }
        else
        {
            loadDefaultController()
        }
        
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resetToLoginController()
    {
        let settings: AppSettings = AppSettings()
        if settings.hasPasswordEnabled()
        {
            if nil != customNavigationController
            {
                customNavigationController!.view.removeFromSuperview()
                customNavigationController!.removeFromParentViewController()
            }
            loadLoginController()
        }
    }
    
    func loadLoginController()
    {
        var storyboard: UIStoryboard = UIStoryboard(name: "PWESMainStoryboard", bundle: nil)
        
        var loginController: PWESLoginViewController = storyboard.instantiateViewControllerWithIdentifier("loginViewController") as! PWESLoginViewController
        loginController.loginHandler = self
        self.defaultLoginController = loginController        
        self.view.addSubview(loginController.view)
        //        addChildViewController(loginController)
        loginController.didMoveToParentViewController(self)
        
    }
        
    func loadDefaultController()
    {
        var dashboardController: PWESDashboardViewController = PWESDashboardViewController()
        dashboardController.menuHandler = self
        self.customNavigationController = UINavigationController(rootViewController: dashboardController)
        if nil != self.customNavigationController
        {
            view.addSubview(self.customNavigationController!.view)
            addChildViewController(self.customNavigationController!)
            self.customNavigationController!.didMoveToParentViewController(self)
        }
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

    func dismissMenuPanel(controllerName: String?)
    {
        animateLeftPanel(shouldExpand: false)
        if nil != controllerName
        {
            replaceMainController(controllerName!,importedAttributes: nil)
        }
    }
    
    func addMenuController(menuController: HamburgerMenuTableViewController)
    {
        menuController.menuHandler = self
        view.insertSubview(menuController.view, atIndex: 0)
        addChildViewController(menuController)
        menuController.didMoveToParentViewController(self)
    }
    
    
    func replaceMainController(controllerName: String, importedAttributes: NSDictionary?)
    {
        if nil != self.customNavigationController
        {
            self.customNavigationController!.view.removeFromSuperview()
        }
        self.customNavigationController = nil
        
        if self.traitCollection.horizontalSizeClass == .Regular
        {
            var navController: UINavigationController? = navigationControllerForiPad(controllerName, attributes: importedAttributes)
            if navController == nil
            {
                return
            }
            self.customNavigationController = navController
            
            self.customNavigationController!.view.frame.origin.x = customNavigationController!.view.frame.origin.x + 180.0
            self.view.addSubview(self.customNavigationController!.view)
            self.customNavigationController!.didMoveToParentViewController(self)
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
            var navController: UINavigationController? = navigationControllerForiPhone(controllerName, attributes: importedAttributes)
            if navController == nil
            {
                return
            }
            self.customNavigationController = navController
            self.customNavigationController!.view.transform = CGAffineTransformMakeScale(0.8, 0.8)
            self.customNavigationController!.view.frame.origin.x = CGRectGetWidth(customNavigationController!.view.frame) - 80
            self.view.addSubview(self.customNavigationController!.view)
            self.customNavigationController!.didMoveToParentViewController(self)
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
                animateCenterPanelXPosition(targetPosition: customNavigationController!.view.frame.origin.x + 210.0)
            }
            else
            {
                zoomOutMainController(targetPosition: CGRectGetWidth(customNavigationController!.view.frame) - 80)
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
            self.customNavigationController!.view.transform = CGAffineTransformMakeScale(0.8, 0.8)
            self.customNavigationController!.view.frame.origin.x = targetPosition
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
            
            self.customNavigationController!.view.transform = CGAffineTransformIdentity
            self.customNavigationController!.view.frame.origin.x = self.view.frame.origin.x
            }, completion: completion)
    }
    
    /**
    sliding in/out
    */
    func animateCenterPanelXPosition(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil)
    {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.customNavigationController!.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    
    func navigationControllerForiPad(controllerName: String, attributes: NSDictionary?) -> UINavigationController?
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
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kProceduresController
        {
            var controller: ProceduresCollectionViewController = ProceduresCollectionViewController()
            controller.menuHandler = self
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

    func navigationControllerForiPhone(controllerName: String, attributes: NSDictionary?) -> UINavigationController?
    {
        var navigationController: UINavigationController?
        if controllerName == kResultsController
        {
            var controller: ResultsListTableViewController = ResultsListTableViewController()
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
            var controller: MyHIVMedicationViewController = MyHIVMedicationViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kOtherMedsController
        {
            var controller: OtherMedicationsListTableViewController = OtherMedicationsListTableViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kSideEffectsController
        {
            var controller: SideEffectsTableViewController = SideEffectsTableViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kMissedController
        {
            var controller: MissedMedicationsTableViewController = MissedMedicationsTableViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kMedicationDiaryController
        {
            var controller: PWESSeinfeldViewController = PWESSeinfeldViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kProceduresController
        {
            var controller: ProceduresListTableViewController = ProceduresListTableViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kClinicsController
        {
            var controller: ClinicalAddressTableViewController = ClinicalAddressTableViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kAlertsController
        {
            var controller: NotificationAlertsTableViewController = NotificationAlertsTableViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        return navigationController
    }
    
    func didLogin()
    {
        if nil == defaultLoginController
        {
            return
        }
        defaultLoginController!.view.removeFromSuperview()
        defaultLoginController!.removeFromParentViewController()
        self.defaultLoginController = nil
        loadDefaultController()
    }
    
    func didLoginFailed()
    {
    }
    
}
