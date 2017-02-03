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
        let storyboard: UIStoryboard = UIStoryboard(name: "PWESMainStoryboard", bundle: nil)
        
        let loginController: PWESLoginViewController = storyboard.instantiateViewController(withIdentifier: "loginViewController") as! PWESLoginViewController
        loginController.loginHandler = self
        self.defaultLoginController = loginController        
        self.view.addSubview(loginController.view)
        //        addChildViewController(loginController)
        loginController.didMove(toParentViewController: self)
        
    }
        
    func loadDefaultController()
    {
        let dashboardController: PWESDashboardViewController = PWESDashboardViewController()
        dashboardController.menuHandler = self
        self.customNavigationController = UINavigationController(rootViewController: dashboardController)
        if nil != self.customNavigationController
        {
            view.addSubview(self.customNavigationController!.view)
            addChildViewController(self.customNavigationController!)
            self.customNavigationController!.didMove(toParentViewController: self)
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

    func dismissMenuPanel(_ controllerName: String?)
    {
        animateLeftPanel(shouldExpand: false)
        if let name = controllerName
        {
            replaceMainController(name, importedAttributes: nil)
        }
    }
    
    func addMenuController(_ menuController: HamburgerMenuTableViewController)
    {
        menuController.menuHandler = self
        view.insertSubview(menuController.view, at: 0)
        addChildViewController(menuController)
        menuController.didMove(toParentViewController: self)
    }
    
    
    func replaceMainController(_ controllerName: String, importedAttributes: NSDictionary?)
    {
        if nil != customNavigationController
        {
            customNavigationController!.view.removeFromSuperview()
        }
        customNavigationController = nil
        
        if self.traitCollection.horizontalSizeClass == .regular
        {
            if let navController: UINavigationController = navigationControllerForiPad(controllerName, attributes: importedAttributes)
            {
                self.customNavigationController = navController
                
                navController.view.frame.origin.x = navController.view.frame.origin.x + 180.0
                self.view.addSubview(navController.view)
                navController.didMove(toParentViewController: self)
                animateCenterPanelXPosition(targetPosition: 0) { finished in
                    self.isCollapsed = true
                    
                    if let menu = self.menuController
                    {
                        menu.view.removeFromSuperview()
                        self.menuController = nil;
                    }
                }
            }
        }
        else
        {
            if let navController: UINavigationController = navigationControllerForiPhone(controllerName, attributes: importedAttributes) {
                self.customNavigationController = navController
                navController.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                navController.view.frame.origin.x = navController.view.frame.width - 80
                self.view.addSubview(navController.view)
                navController.didMove(toParentViewController: self)
                zoomInMainController(targetPosition: 0) { finished in
                    self.isCollapsed = true
                    if let menu = self.menuController
                    {
                        menu.view.removeFromSuperview()
                        self.menuController = nil;
                    }
                }
                
            }
        }
        
    }
    
    
    
    func animateLeftPanel(shouldExpand: Bool)
    {
        let isRegular : Bool = self.traitCollection.horizontalSizeClass == .regular
        
        if (shouldExpand)
        {
            isCollapsed = false
            if isRegular
            {
                animateCenterPanelXPosition(targetPosition:customNavigationController!.view.frame.origin.x + 210.0)
            }
            else
            {
                zoomOutMainController(targetPosition:(customNavigationController!.view.frame).width - 80)
            }
        }
        else
        {
            if isRegular
            {
                animateCenterPanelXPosition(targetPosition: 0) { finished in
                    self.isCollapsed = true
                    if let menu = self.menuController {
                        menu.view.removeFromSuperview()
                    }
                    self.menuController = nil;
                }
            }
            else
            {
                zoomInMainController(targetPosition: 0) { finished in
                    self.isCollapsed = true
                    
                    if let menu = self.menuController {
                        menu.view.removeFromSuperview()
                    }
                    self.menuController = nil;
                }
            }
        }
    }
    
    
    
    /**
    ZOOM in/out methods
    */
    func zoomOutMainController(targetPosition: CGFloat, _ completion: ((Bool) -> Void)! = nil)
    {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
            if let navController = self.customNavigationController {
                navController.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                navController.view.frame.origin.x = targetPosition
            }
            }, completion: completion)
        
    }
    
    func zoomInMainController(targetPosition: CGFloat, _ completion: ((Bool) -> Void)! = nil)
    {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
            if let navController = self.customNavigationController {
                navController.view.transform = CGAffineTransform.identity
                navController.view.frame.origin.x = self.view.frame.origin.x

            }
            
            }, completion: completion)
    }
    
    /**
    sliding in/out
    */
    func animateCenterPanelXPosition(targetPosition: CGFloat, _ completion: ((Bool) -> Void)! = nil)
    {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            if let navController = self.customNavigationController {
                navController.view.frame.origin.x = targetPosition
    
            }
            }, completion: completion)
    }
    
    
    func navigationControllerForiPad(_ controllerName: String, attributes: NSDictionary?) -> UINavigationController?
    {
        var navigationController: UINavigationController?
        if controllerName == kResultsController
        {
            let controller: ResultsCollectionViewController = ResultsCollectionViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kDashboardController
        {
            let controller: PWESDashboardViewController = PWESDashboardViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
//        else if controllerName == kDropboxController
//        {
//            let controller: DropboxViewController = DropboxViewController()
//            controller.menuHandler = self
//            navigationController = UINavigationController(rootViewController: controller)
//        }
        else if controllerName == kHIVMedsController
        {
            let controller: MyHIVCollectionViewController = MyHIVCollectionViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kOtherMedsController
        {
            let controller: OtherMedsCollectionViewController = OtherMedsCollectionViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kSideEffectsController
        {
            let controller: SideEffectsCollectionViewController = SideEffectsCollectionViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kMissedController
        {
            let controller: MissedMedicationCollectionViewController = MissedMedicationCollectionViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kMedicationDiaryController
        {
            let controller: PWESSeinfeldCollectionViewController = PWESSeinfeldCollectionViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kProceduresController
        {
            let controller: ProceduresCollectionViewController = ProceduresCollectionViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kClinicsController
        {
            let controller: ClinicAddressCollectionViewController = ClinicAddressCollectionViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kAlertsController
        {
            let controller: NotificationsAlertsCollectionViewController = NotificationsAlertsCollectionViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        return navigationController
    }

    func navigationControllerForiPhone(_ controllerName: String, attributes: NSDictionary?) -> UINavigationController?
    {
        var navigationController: UINavigationController?
        if controllerName == kResultsController
        {
            let controller: ResultsListTableViewController = ResultsListTableViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kDashboardController
        {
            let controller: PWESDashboardViewController = PWESDashboardViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
//        else if controllerName == kDropboxController
//        {
//            let controller: DropboxViewController = DropboxViewController()
//            controller.menuHandler = self
//            navigationController = UINavigationController(rootViewController: controller)
//        }
        else if controllerName == kHIVMedsController
        {
            let controller: MyHIVMedicationViewController = MyHIVMedicationViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kOtherMedsController
        {
            let controller: OtherMedicationsListTableViewController = OtherMedicationsListTableViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kSideEffectsController
        {
            let controller: SideEffectsTableViewController = SideEffectsTableViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kMissedController
        {
            let controller: MissedMedicationsTableViewController = MissedMedicationsTableViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kMedicationDiaryController
        {
            let controller: PWESSeinfeldViewController = PWESSeinfeldViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kProceduresController
        {
            let controller: ProceduresListTableViewController = ProceduresListTableViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kClinicsController
        {
            let controller: ClinicalAddressTableViewController = ClinicalAddressTableViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        else if controllerName == kAlertsController
        {
            let controller: NotificationAlertsTableViewController = NotificationAlertsTableViewController()
            controller.menuHandler = self
            navigationController = UINavigationController(rootViewController: controller)
        }
        return navigationController
    }
    
    func didLogin()
    {
        if let loginController = defaultLoginController
        {
            loginController.view.removeFromSuperview()
            loginController.removeFromParentViewController()
            self.defaultLoginController = nil
            loadDefaultController()
        }
    }
    
    func didLoginFailed()
    {
    }
    
}
