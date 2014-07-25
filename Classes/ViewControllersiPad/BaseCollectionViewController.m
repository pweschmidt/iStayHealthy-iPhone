//
//  BaseCollectionViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/11/2013.
//
//

#import "BaseCollectionViewController.h"
#import "CoreDataConstants.h"
#import "CoreDataManager.h"
#import "Constants.h"
#import "CustomToolbar.h"
#import "UILabel+Standard.h"
#import "UIFont+Standard.h"
#import "ContentNavigationController_iPad.h"
#import "Utilities.h"
#import "SettingsTableViewController.h"
#import "InformationTableViewController.h"
#import "DropboxViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "EmailViewController.h"
#import "CoreXMLWriter.h"

#define kHeaderViewIdentifier @"CollectionHeaderViewIdentifier"

@interface BaseCollectionViewController ()
@property (nonatomic, assign) BOOL settingMenuShown;
@end

@implementation BaseCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerObservers];
    self.navigationController.navigationBar.tintColor = TEXTCOLOUR;
    self.settingMenuShown = NO;
    self.customPopoverController = nil;
    self.collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionViewLayout.itemSize = CGSizeMake(150, 150);
    self.collectionViewLayout.headerReferenceSize = CGSizeMake(self.view.bounds.size.width - 40, 40);
    self.collectionViewLayout.minimumInteritemSpacing = 20;
    self.collectionViewLayout.minimumLineSpacing = 20;

    CGRect frame = CGRectMake(20, 44, self.view.frame.size.width - 40, self.view.frame.size.height - 88);
    CGRect toolbarFrame = CGRectMake(0, self.view.bounds.size.height - 44, self.view.bounds.size.width, 44);
    if (UIDeviceOrientationIsLandscape(self.interfaceOrientation))
    {
        frame = CGRectMake(20, 44, frame.size.height - 88, frame.size.width - 40);
        toolbarFrame = CGRectMake(0, self.view.frame.size.width - 44, self.view.frame.size.height, 44);
    }

    self.collectionView = [[UICollectionView alloc] initWithFrame:frame
                                             collectionViewLayout:self.collectionViewLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.bounces = YES;
    self.collectionView.scrollEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = YES;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.collectionView];

    CustomToolbar *toolbar = [[CustomToolbar alloc] initWithFrame:toolbarFrame];
    [self.view addSubview:toolbar];
    self.toolbar = toolbar;
    self.toolbar.customToolbarDelegate = self;

    UIImage *menuImage = [UIImage imageNamed:@"menu.png"];
    UIImageView *menuView = [[UIImageView alloc] initWithImage:menuImage];
    menuView.backgroundColor = [UIColor clearColor];
    menuView.frame = CGRectMake(0, 0, 20, 20);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 20, 20);
    button.backgroundColor = [UIColor clearColor];
    [button addSubview:menuView];
    [button addTarget:self action:@selector(settingsMenu) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];

    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderViewIdentifier];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if ([Utilities isIPad])
    {
        [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
        [UIView animateWithDuration:0.25 animations: ^{
             self.collectionView.alpha = 0.0;
             self.toolbar.alpha = 0.0;
         } completion: ^(BOOL finished) {
             self.collectionView.alpha = 1.0;
             self.toolbar.alpha = 1.0;
             CGRect frame = CGRectMake(20, 44, self.view.bounds.size.width - 40, self.view.bounds.size.height - 88);
             CGRect toolbarFrame = CGRectMake(0, self.view.bounds.size.height - 44, self.view.bounds.size.width, 44);
             self.toolbar.frame = toolbarFrame;
             self.collectionView.frame = frame;
             [self.collectionView.collectionViewLayout invalidateLayout];
         }];
    }
}

- (void)hidePopover
{
    if (nil != self.customPopoverController)
    {
        [self.customPopoverController dismissPopoverAnimated:YES];
        self.customPopoverController = nil;
    }
}

- (void)presentPopoverWithController:(UINavigationController *)controller
                            fromRect:(CGRect)frame
{
    self.customPopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
    self.customPopoverController.delegate = self;
    [self.customPopoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)presentPopoverWithController:(UINavigationController *)controller
                       fromBarButton:(UIBarButtonItem *)barButton
{
    [self presentPopoverWithController:controller fromBarButton:barButton direction:UIPopoverArrowDirectionAny];
}

- (void)presentPopoverWithController:(UINavigationController *)controller
                       fromBarButton:(UIBarButtonItem *)barButton
                           direction:(UIPopoverArrowDirection)direction
{
    self.customPopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
    self.customPopoverController.delegate = self;
    [self.customPopoverController presentPopoverFromBarButtonItem:barButton
                                         permittedArrowDirections:direction
                                                         animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [self unregisterObservers];
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

- (void)settingsMenu
{
    if ([self.parentViewController isKindOfClass:[ContentNavigationController_iPad class]])
    {
        ContentNavigationController_iPad *navController = (ContentNavigationController_iPad *) self.parentViewController;
        if (self.settingMenuShown)
        {
            [navController hideMenu];
            self.settingMenuShown = NO;
        }
        else
        {
            [navController showMenu];
            self.settingMenuShown = YES;
        }
    }
}

- (void)addButtonPressed:(id)sender
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
}

- (void)setTitleViewWithTitle:(NSString *)titleString
{
    if (nil == titleString)
    {
        return;
    }
    CGFloat width = 180;
    CGFloat height = 44;
    CGFloat logoWidth = 29;
    CGFloat pozWidth = 45;
    CGFloat labelWidth = 180 - 29 - 45;
    CGFloat topOffset = (44 - 29) / 2;
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, width, height);

    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_29.png"]];
    logo.frame = CGRectMake(0, topOffset, logoWidth, logoWidth);
    logo.layer.cornerRadius = 6;
    logo.layer.masksToBounds = YES;
    UIImageView *poz = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pozicon.png"]];
    poz.frame = CGRectMake(width - pozWidth, topOffset, pozWidth, logoWidth);
    poz.layer.cornerRadius = 6;
    poz.layer.masksToBounds = YES;

    [button addSubview:logo];
    [button addSubview:poz];

    UILabel *titleLabel = [UILabel standardLabel];
    titleLabel.text = titleString;
    titleLabel.frame = CGRectMake(logoWidth, 0, labelWidth, height);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithType:Standard size:17];
    titleLabel.numberOfLines = 0;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;

    [button addSubview:titleLabel];
    [button addTarget:self
               action:@selector(goToPOZSite)
     forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:button];
    self.navigationItem.titleView = titleView;
}

- (void)goToPOZSite
{
#ifdef APPDEBUG
    NSLog(@"navigation button clicked");
#endif
}

#pragma mark Collection View delegate methods. Override in sub classes
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]                                 userInfo:nil];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]                                 userInfo:nil];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]                                 userInfo:nil];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view = nil;

    if (UICollectionElementKindSectionHeader == kind)
    {
        view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderViewIdentifier forIndexPath:indexPath];
    }

    return view;
}

#pragma mark Core Data and other methods to override in subclasses
- (void)reloadSQLData:(NSNotification *)notification
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
}

- (void)startAnimation:(NSNotification *)notification
{
    [self animateViewWithText:NSLocalizedString(@"Loading data...", nil)];
}

- (void)stopAnimation:(NSNotification *)notification
{
    [self stopAnimateView];
}

- (void)handleError:(NSNotification *)notification
{
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error loading data", nil) message:NSLocalizedString(@"An error occurred while loading data", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil];

    [view show];
}

- (void)handleStoreChanged:(NSNotification *)notification
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
}

#pragma mark PWESToolbar delegate methods
- (void)showPasswordControllerFromButton:(UIBarButtonItem *)button
{
    SettingsTableViewController *controller = [[SettingsTableViewController alloc] initAsPopoverController];

    controller.popoverDelegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];

    [self presentPopoverWithController:navController fromBarButton:button direction:UIPopoverArrowDirectionDown];
}

- (void)showMailControllerHasAttachment:(BOOL)hasAttachment
{
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];

    mailController.navigationController.navigationBar.tintColor = [UIColor blackColor];

    NSArray *toRecipient = [NSArray arrayWithObjects:@"istayhealthy.app@gmail.com", nil];
    mailController.mailComposeDelegate = self;
    [mailController setToRecipients:toRecipient];
    [mailController setSubject:@"Feedback for iStayHealthy iPhone app"];
    if (hasAttachment)
    {
        CoreXMLWriter *writer = [CoreXMLWriter sharedInstance];
        NSString *dataPath = [self uploadFileTmpPath];

        [writer writeWithCompletionBlock: ^(NSString *xmlString, NSError *error) {
             if (nil != xmlString)
             {
                 NSData *xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
                 NSError *writeError = nil;
                 [xmlData writeToFile:dataPath options:NSDataWritingAtomic error:&writeError];
                 if (writeError)
                 {
                     [[[UIAlertView alloc]
                       initWithTitle:NSLocalizedString(@"Error writing data to tmp directory", nil) message:[error localizedDescription]
                            delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
                      show];
                 }
                 else
                 {
                     MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];

                     mailController.navigationController.navigationBar.tintColor = [UIColor blackColor];
                     mailController.mailComposeDelegate = self;
                     [mailController addAttachmentData:xmlData mimeType:@"application/xml" fileName:dataPath];
                     [mailController setSubject:@"iStayHealthy Data (attached)"];
                     [self.navigationController presentViewController:mailController animated:YES completion:nil];
                 }
             }
         }];
//		CoreCSVWriter *writer = [CoreCSVWriter sharedInstance];
//		[writer writeWithCompletionBlock: ^(NSString *csvString, NSError *error) {
//		    dispatch_async(dispatch_get_main_queue(), ^{
//		        if (nil != csvString)
//		        {
//		            NSData *data = [csvString dataUsingEncoding:NSUTF8StringEncoding];
//		            [mailController addAttachmentData:data mimeType:@"text/csv" fileName:@"iStayHealthy.csv"];
//				}
//		        else
//		        {
//		            [[[UIAlertView alloc]
//		              initWithTitle:@"Error adding attachment" message:[error localizedDescription]
//		                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
//		             show];
//				}
//		        [self.navigationController presentViewController:mailController animated:YES completion:nil];
//			});
//		}];
    }
    else
    {
        [self.navigationController presentViewController:mailController animated:YES completion:nil];
    }
}

- (NSString *)uploadFileTmpPath
{
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"iStayHealthy.isth"];
}

- (void)showDropboxControllerFromButton:(UIBarButtonItem *)button
{
    if ([[DBSession sharedSession] isLinked])
    {
        DropboxViewController *controller = [[DropboxViewController alloc] initAsPopoverController];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentPopoverWithController:navController fromBarButton:button direction:UIPopoverArrowDirectionDown];
    }
    else
    {
        [[DBSession sharedSession] linkFromController:self];
    }
}

- (void)showInfoControllerFromButton:(UIBarButtonItem *)button
{
    InformationTableViewController *controller = [[InformationTableViewController alloc] initAsPopoverController];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];

    [self presentPopoverWithController:navController fromBarButton:button direction:UIPopoverArrowDirectionDown];
}

- (void)showHelpControllerFromButton:(UIBarButtonItem *)button
{
}

#pragma mark Mail composer callback
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark animating
- (void)createIndicatorsInView:(UIView *)collectionView
{
    UILabel *label = [UILabel standardLabel];

    label.text = @"";
    label.frame = CGRectMake(80, 0, collectionView.bounds.size.width - 100, 36);
    [collectionView addSubview:label];
    self.activityLabel = label;
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.hidesWhenStopped = YES;
    indicator.frame = CGRectMake(20, 0, 36, 36);
    [collectionView addSubview:indicator];
    self.indicatorView = indicator;
}

- (void)animateViewWithText:(NSString *)text
{
    if (nil != self.activityLabel)
    {
        self.activityLabel.text = text;
    }
    if (nil != self.indicatorView && !self.indicatorView.isAnimating)
    {
        [self.indicatorView startAnimating];
    }
}

- (void)stopAnimateView
{
    if (nil != self.activityLabel)
    {
        self.activityLabel.text = @"";
    }
    if (nil != self.indicatorView && self.indicatorView.isAnimating)
    {
        [self.indicatorView stopAnimating];
    }
}

@end
