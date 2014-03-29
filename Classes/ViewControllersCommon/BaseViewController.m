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
#import "Utilities.h"
#import "Menus.h"
#import "UILabel+Standard.h"
#import "UIFont+Standard.h"
#import "CustomToolbar.h"

@interface BaseViewController ()
@end

@implementation BaseViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self registerObservers];
	self.view.backgroundColor = DEFAULT_BACKGROUND;
	UIImage *menuImage = [UIImage imageNamed:@"menu.png"];
	UIImageView *menuView = [[UIImageView alloc] initWithImage:menuImage];
	menuView.backgroundColor = [UIColor clearColor];
	menuView.frame = CGRectMake(0, 0, 20, 20);
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0, 0, 20, 20);
	button.backgroundColor = [UIColor clearColor];
	[button addSubview:menuView];
	[button addTarget:self action:@selector(hamburgerMenu) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:button];
	self.navigationItem.leftBarButtonItem = menuButton;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];

	if ([Utilities isIPad])
	{
		CGRect toolbarFrame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
		CustomToolbar *toolbar = [[CustomToolbar alloc] initWithFrame:toolbarFrame];
		[self.view addSubview:toolbar];
		self.iPadToolbar = toolbar;
	}
}

- (void)disableRightBarButtons
{
	self.navigationItem.rightBarButtonItem = nil;
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
	[button    addTarget:self
	              action:@selector(goToPOZSite)
	    forControlEvents:UIControlEventTouchUpInside];
	[titleView addSubview:button];
	self.navigationItem.titleView = titleView;
}

- (void)goToPOZSite
{
	NSLog(@"navigation button clicked");
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
- (void)hamburgerMenu
{
	if ([self.parentViewController isKindOfClass:[ContentNavigationController class]])
	{
		ContentNavigationController *navController = (ContentNavigationController *)self.parentViewController;
		[navController showMenu];
	}
}

- (void)addButtonPressed:(id)sender
{
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
	                               reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
	                             userInfo:nil];
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

- (UIImage *)blankImage
{
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(55, 55), NO, 0.0);
	UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return blank;
}

@end
