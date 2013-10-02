//
//  BaseViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 10/08/2013.
//
//

#import "BaseViewController.h"
#import "CoreDataConstants.h"
#import "ContentContainerViewController.h"
#import "ContentNavigationController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "GeneralSettings.h"
#import "Constants.h"
#import "CustomTableView.h"
#import "Utilities.h"
#import "Menus.h"

@interface BaseViewController ()
@property (nonatomic, assign) BOOL hamburgerMenuIsShown;
@property (nonatomic, assign) BOOL addMenuIsShown;
@end

@implementation BaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hamburgerMenuIsShown = NO;
    self.addMenuIsShown = NO;
    self.view.backgroundColor = DEFAULT_BACKGROUND;
    if ([Utilities isIPad])
    {
        offScreenLeft = CGRectMake(-200, 0, 200, self.view.frame.size.height);
        onScreenLeft = CGRectMake(0, 0, 200, self.view.frame.size.height);
        offScreenRight = CGRectMake(self.view.frame.size.width, 0, 200, self.view.frame.size.height);
        onScreenRight = CGRectMake(self.view.frame.size.width - 200, 0, 200, self.view.frame.size.height);
        mainFrameCenter = self.view.frame;
        mainFrameToLeft = CGRectMake(self.view.frame.origin.x - 200, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
        mainFrameToRight = CGRectMake(self.view.frame.origin.x +200, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
        [self configureIPadMenus];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(slideInHamburger)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(slideInAdder)];
    }
    else
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(settingsMenu)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMenu)];
    }
    [self registerObservers];
}

- (void)dealloc
{
    [self unregisterObservers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)registerObservers
{
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(reloadSQLData:)
     name:kLoadedStoreNotificationKey
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleError:)
     name:kErrorStoreNotificationKey
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleStoreChanged:)
     name:NSPersistentStoreCoordinatorStoresDidChangeNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(reloadSQLData:)
     name:NSManagedObjectContextDidSaveNotification
     object:nil];
}

- (void)unregisterObservers
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:kLoadedStoreNotificationKey
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:kErrorStoreNotificationKey
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:NSPersistentStoreCoordinatorStoresDidChangeNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:NSManagedObjectContextDidSaveNotification
     object:nil];
    
}

- (void)reloadSQLData:(NSNotification *)notification
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
}
- (void)startAnimation:(NSNotification *)notification
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
}
- (void)stopAnimation:(NSNotification *)notification
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
    
}
- (void)handleError:(NSNotification *)notification
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
}

- (void)handleStoreChanged:(NSNotification *)notification
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
}

#pragma mark - iPhone Menus
- (void)settingsMenu
{
    [(ContentNavigationController *)self.parentViewController transitionToNavigationControllerWithName:kMenuController];
}

- (void)addMenu
{
    [(ContentNavigationController *)self.parentViewController transitionToNavigationControllerWithName:kAddController];
}

- (void)addButtonPressed:(id)sender
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
}


#pragma mark - iPad handling
- (void)configureIPadMenus
{
    CustomTableView *hamburgerMenus = [CustomTableView
                                       customTableViewWithMenus:[Menus hamburgerMenus]
                                       frame:offScreenLeft
                                       type:HamburgerMenuType];
    hamburgerMenus.containerDelegate = self;
    [self.view addSubview:hamburgerMenus];
    self.iPadHamburgerMenuView = hamburgerMenus;
    CustomTableView *addMenus = [CustomTableView
                                 customTableViewWithMenus:[Menus addMenus]
                                 frame:offScreenRight
                                 type:AddMenuType];
    addMenus.containerDelegate = self;
    [self.view addSubview:addMenus];
    self.iPadAddMenuView = addMenus;
}

#pragma mark - iPad controller delegate methods
- (void)slideOutHamburgerToNavController:(NSString *)navController
{
    [UIView beginAnimations:@"slideOutHamburger" context:nil];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    self.iPadHamburgerMenuView.frame = offScreenLeft;
    [self.iPadHamburgerMenuView setNeedsDisplay];
    self.view.alpha = 1.0;
//    self.view.frame = mainFrameCenter;
    self.navigationController.navigationBar.alpha = 1.0;
    self.hamburgerMenuBarButton.enabled = YES;
    self.addMenuBarButton.enabled = YES;
    [UIView commitAnimations];
    if (nil != navController)
    {
        if ([navController isEqualToString:kDropboxController])
        {
            if (![[DBSession sharedSession] isLinked])
            {
                [[DBSession sharedSession] linkFromController:self];
            }
            else
            {
                [(ContentContainerViewController *)self.parentViewController transitionToNavigationControllerWithName:navController];
            }
        }
        else
        {
            [(ContentNavigationController *)self.parentViewController transitionToNavigationControllerWithName:navController];
        }
    }
    self.hamburgerMenuIsShown = NO;
}

- (void)slideInHamburger
{
    [UIView beginAnimations:@"slideInHamburger" context:nil];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    self.iPadHamburgerMenuView.frame = onScreenLeft;
    self.iPadHamburgerMenuView.alpha = 1.0;
    [self.iPadHamburgerMenuView setNeedsDisplay];
    self.view.alpha = 0.6;
//    self.view.frame = mainFrameToRight;
    self.navigationController.navigationBar.alpha = 0.6;
    self.hamburgerMenuBarButton.enabled = NO;
    self.addMenuBarButton.enabled = NO;
    [UIView commitAnimations];
    self.hamburgerMenuIsShown = YES;
}

- (void)slideInAdder
{
    [UIView beginAnimations:@"slideInHamburger" context:nil];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    self.iPadAddMenuView.frame = onScreenRight;
    self.iPadAddMenuView.alpha = 1.0;
    [self.iPadAddMenuView setNeedsDisplay];
    self.view.alpha = 0.6;
//    self.view.frame = mainFrameToLeft;
    self.navigationController.navigationBar.alpha = 0.6;
    self.hamburgerMenuBarButton.enabled = NO;
    self.addMenuBarButton.enabled = NO;
    [UIView commitAnimations];
    self.addMenuIsShown = YES;
}

- (void)slideOutAdderToNavController:(NSString *)navController
{
    [UIView beginAnimations:@"slideOutAdder" context:nil];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.iPadAddMenuView.frame = offScreenRight;
    [self.iPadAddMenuView setNeedsDisplay];
    self.view.alpha = 1.0;
//    self.view.frame = mainFrameCenter;
    self.navigationController.navigationBar.alpha = 1.0;
    self.hamburgerMenuBarButton.enabled = YES;
    self.addMenuBarButton.enabled = YES;
    [UIView commitAnimations];
    if (nil != navController)
    {
        [(ContentNavigationController *)self.parentViewController transitionToNavigationControllerWithName:navController];
    }
    self.addMenuIsShown = NO;
}

#pragma mark - handle rotations (iPad only)
- (BOOL)shouldAutorotate
{
    if ([Utilities isIPad])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([Utilities isIPad])
    {
        return UIInterfaceOrientationMaskAll;
    }
    else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (self.hamburgerMenuIsShown)
    {
        [self slideOutHamburgerToNavController:nil];
    }
    if (self.addMenuIsShown)
    {
        [self slideOutAdderToNavController:nil];
    }
}


@end
