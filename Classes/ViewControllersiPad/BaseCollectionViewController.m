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

@interface BaseCollectionViewController ()

@end

@implementation BaseCollectionViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self registerObservers];
	self.collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
	self.collectionViewLayout.itemSize = CGSizeMake(150, 150);
	self.collectionViewLayout.headerReferenceSize = CGSizeMake(self.view.frame.size.width - 40, 100);
	self.collectionViewLayout.minimumInteritemSpacing = 20;
	self.collectionViewLayout.minimumLineSpacing = 20;
	self.collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;

	CGRect frame = self.view.bounds;
	if (UIDeviceOrientationIsLandscape(self.interfaceOrientation))
	{
		frame = CGRectMake(20, 44, frame.size.height - 88, frame.size.width - 40);
	}
	else
	{
		frame = CGRectMake(20, 44, frame.size.width - 40, frame.size.height - 88);
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
	CGRect toolbarFrame = CGRectMake(0, self.view.bounds.size.height - 44, self.view.bounds.size.width, 44);
	CustomToolbar *toolbar = [[CustomToolbar alloc] initWithFrame:toolbarFrame];
	[self.view addSubview:toolbar];
	self.toolbar = toolbar;

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
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	if ([Utilities isIPad])
	{
		CGRect frame = self.view.bounds;
		CGRect toolbarFrame = CGRectMake(0, self.view.bounds.size.height - 44, self.view.bounds.size.width, 44);
		self.toolbar.frame = toolbarFrame;
		if (UIDeviceOrientationIsLandscape(self.interfaceOrientation))
		{
			frame = CGRectMake(20, 44, frame.size.height - 88, frame.size.width - 40);
		}
		else
		{
			frame = CGRectMake(20, 44, frame.size.width - 40, frame.size.height - 88);
		}
		self.collectionView.frame = frame;
	}
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
		ContentNavigationController_iPad *navController = (ContentNavigationController_iPad *)self.parentViewController;
		[navController showMenu];
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

#pragma mark Core Data and other methods to override in subclasses
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

@end
