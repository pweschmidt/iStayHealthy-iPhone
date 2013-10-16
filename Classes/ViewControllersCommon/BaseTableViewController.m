//
//  BaseTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 10/08/2013.
//
//

#import "BaseTableViewController.h"
#import "CoreDataConstants.h"
#import "ContentContainerViewController.h"
#import "CoreDataManager.h"
#import "ContentNavigationController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "GeneralSettings.h"
#import "Constants.h"
#import "CustomTableView.h"
#import "Utilities.h"
#import "Menus.h"
#import "UILabel+Standard.h"

@interface BaseTableViewController ()
@property (nonatomic, assign) BOOL hamburgerMenuIsShown;
@property (nonatomic, assign) BOOL addMenuIsShown;
@end

@implementation BaseTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.markedObject = nil;
    self.markedIndexPath = nil;
    self.hamburgerMenuIsShown = NO;
    self.addMenuIsShown = NO;
    self.view.backgroundColor = DEFAULT_BACKGROUND;
    if ([Utilities isIPad])
    {
        mainFrameCenter = self.view.frame;
        mainFrameToLeft = CGRectMake(-200, self.view.frame.origin.y, self.view.frame.size.width - 200, self.view.frame.size.height);
        mainFrameToRight = CGRectMake(200, self.view.frame.origin.y, self.view.frame.size.width - 200, self.view.frame.size.height);
        offScreenLeft = CGRectMake(-200, 0, 200, self.view.frame.size.height);
        onScreenLeft = CGRectMake(0, 0, 200, self.view.frame.size.height);
        offScreenRight = CGRectMake(self.view.frame.size.width, 0, 200, self.view.frame.size.height);
        onScreenRight = CGRectMake(self.view.frame.size.width - 200, 0, 200, self.view.frame.size.height);
        [self configureIPadMenus];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(slideInHamburger)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(slideInAdder)];
    }
    else
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(settingsMenu)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
    }
    [self registerObservers];
}

- (void)setTitleViewWithTitle:(NSString *)titleString
{
    if (nil == titleString)
    {
        return;
    }
    self.navigationItem.titleView = nil;
    CGRect navigationFrame = self.navigationController.navigationBar.bounds;
    CGRect titleFrame = CGRectMake(navigationFrame.origin.x + navigationFrame.size.width/4, navigationFrame.origin.y, navigationFrame.size.width/2, navigationFrame.size.height);
    UIImage *pozIcon = [UIImage imageNamed:@"pozicon.png"];
    UIImage *icon = [UIImage imageNamed:@"icon_29.png"];
    
    UIView *titleView = [[UIView alloc] initWithFrame:titleFrame];
    titleView.backgroundColor = [UIColor clearColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = titleFrame;
    button.backgroundColor = [UIColor clearColor];
    UIImageView *logoView = [[UIImageView alloc] initWithImage:icon];
    logoView.frame = CGRectMake(0, titleFrame.origin.y + 29/2, 29, 29);
    logoView.backgroundColor = [UIColor clearColor];
    UIImageView *pozView = [[UIImageView alloc] initWithImage:pozIcon];
    pozView.frame = CGRectMake(titleFrame.size.width - 45, titleFrame.origin.y + 29/2, 45, 29);
    pozView.backgroundColor = [UIColor clearColor];
    UILabel *label = [UILabel standardLabel];
    label.text = titleString;
    label.frame = CGRectMake(titleFrame.origin.x + 29, 0, titleFrame.size.width - 29 - 45, titleFrame.size.height);
    label.textAlignment = NSTextAlignmentCenter;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    
    [button addSubview:logoView];
    [button addSubview:label];
    [button addSubview:pozView];
    [button addTarget:self action:@selector(goToPOZSite) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:button];
    self.navigationItem.titleView = titleView;
}

- (void)goToPOZSite
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [self unregisterObservers];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
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

- (void)addButtonPressed:(id)sender
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
    self.tableView.alpha = 1.0;
    self.tableView.frame = mainFrameCenter;
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
    self.tableView.alpha = 0.9;
    self.navigationController.navigationBar.alpha = 0.9;
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
    self.tableView.alpha = 0.9;
    self.navigationController.navigationBar.alpha = 0.9;
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
    self.tableView.alpha = 1.0;
    self.navigationController.navigationBar.alpha = 1.0;
    self.hamburgerMenuBarButton.enabled = YES;
    self.addMenuBarButton.enabled = YES;
    [UIView commitAnimations];
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


- (void)showDeleteAlertView
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Delete?", @"Delete?") message:NSLocalizedString(@"Do you want to delete this entry?", @"Do you want to delete this entry?") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"Yes", @"Yes"), nil];
    
    [alert show];
}

/**
 if user really wants to delete the entry call removeSQLEntry
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:NSLocalizedString(@"Yes", @"Yes")])
    {
        [self removeSQLEntry];
    }
}

- (void)removeSQLEntry
{
    if (nil == self.markedObject)
    {
        return;
    }
    NSManagedObjectContext *defaultContext = [[CoreDataManager sharedInstance] defaultContext];
    [defaultContext deleteObject:self.markedObject];
//    [self.tableView deleteRowsAtIndexPaths:@[self.markedIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
    NSError *error = nil;
    [[CoreDataManager sharedInstance] saveContextAndWait:&error];
    self.markedObject = nil;
    self.markedIndexPath = nil;
}

- (UIImage *)blankImage
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(55, 55), NO, 0.0);
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return blank;
}

@end
