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
#import <QuartzCore/QuartzCore.h>
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
	CGRect frame = self.view.bounds;
	if (UIDeviceOrientationIsLandscape(self.interfaceOrientation))
	{
		frame = CGRectMake(0, 0, frame.size.height, frame.size.width);
	}
	else
	{
		frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
	}
	UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
	tableView.backgroundColor = DEFAULT_BACKGROUND;
	[self.view addSubview:tableView];
	self.tableView = tableView;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;

	self.markedObject = nil;
	self.markedIndexPath = nil;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	if ([Utilities isIPad])
	{
		CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
		self.tableView.frame = frame;
	}
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

@end
