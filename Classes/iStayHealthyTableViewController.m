//
//  iStayHealthyTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 04/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "iStayHealthyTableViewController.h"
#import "StatusViewControllerLandscape.h"
#import "iStayHealthyAppDelegate.h"
#import "iStayHealthyRecord.h"
#import "WebViewController.h"
#import "GeneralSettings.h"
#import "NSArray-Set.h"
#import "Utilities.h"


@implementation iStayHealthyTableViewController
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize masterRecord, landscapeController, headerView;
@synthesize allMeds, allMissedMeds, allResults, allResultsInReverseOrder;
@synthesize allPills, allContacts, allProcedures, allSideEffects;


#pragma mark -
#pragma mark View lifecycle

/**
 loads the view
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:@"RefetchAllDatabaseData" object:[[UIApplication sharedApplication] delegate]];

#ifdef APPDEBUG
	NSLog(@"iStayHealthyTableViewController::viewDidLoad setup fetchResultsController");
#endif

	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:NSLocalizedString(@"Error Loading Data",nil) 
							  message:[NSString stringWithFormat:NSLocalizedString(@"Error was %@, quitting.", @"Error was %@, quitting"), [error localizedDescription]] 
							  delegate:self 
							  cancelButtonTitle:NSLocalizedString(@"Cancel",nil) 
							  otherButtonTitles:nil];
		[alert show];
        [alert release];
	}
	
#ifdef APPDEBUG
	NSLog(@"iStayHealthyTableViewController::viewDidLoad setup get data");
#endif

	NSArray *records = [self.fetchedResultsController fetchedObjects];
	int count = [records count];

#ifdef APPDEBUG
	NSLog(@"iStayHealthyTableViewController::viewDidLoad number of fetched records is %d",count);
#endif
	
	if (0 == count) {
#ifdef APPDEBUG		
		NSLog(@"iStayHealthyTableViewController::viewDidLoad no master record yet");
#endif
		[self setUpMasterRecord];
	}

	StatusViewControllerLandscape *landscape = [[StatusViewControllerLandscape alloc]initWithNibName:@"StatusViewControllerLandscape" bundle:nil];
	self.landscapeController = landscape;
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:)
												 name:UIDeviceOrientationDidChangeNotification object:nil];
    
    CGRect adFrame = CGRectMake(20.0, 1.0, 280, 29);
    UIButton *addButton = [[UIButton alloc]initWithFrame:adFrame]; 
    [addButton setBackgroundColor:[UIColor clearColor]];
	[addButton addTarget:self action:@selector(loadURL) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imageView = [[[UIImageView alloc] initWithImage:[Utilities bannerImageFromLocale]]autorelease];

    if (nil != imageView) {
        [addButton addSubview:imageView];
    }

    [self.headerView addSubview:addButton];
    [addButton release];
	[landscape release];
}

/**
 reloads the data when getting notified by the app data that iCloud data have changed
 */
- (void)reloadData:(NSNotification*)note{
#ifdef APPDEBUG
    NSLog(@"We are getting notified to reload the data");
#endif
    NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:NSLocalizedString(@"Error Loading Data",nil) 
							  message:[NSString stringWithFormat:NSLocalizedString(@"Error was %@, quitting.", @"Error was %@, quitting"), [error localizedDescription]] 
							  delegate:self 
							  cancelButtonTitle:NSLocalizedString(@"Cancel",nil) 
							  otherButtonTitles:nil];
		[alert show];
        [alert release];
	}
    if (note) {
        [self setUpData];
        [self.tableView reloadData];        
    }
}

/**
 */
- (void)gotoPOZ{
    NSString *url = @"http://www.poz.com";
    NSString *title = @"POZ Magazine";
    WebViewController *webViewController = [[WebViewController alloc]initWithURLString:url withTitle:title];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    UINavigationBar *navigationBar = [navigationController navigationBar];
    navigationBar.tintColor = [UIColor blackColor];
    [self presentModalViewController:navigationController animated:YES];
    [webViewController release];
    [navigationController release];    
    
}



/**
 */
- (void)loadURL{
    NSString *url = [Utilities urlStringFromLocale];
    NSString *title = [Utilities titleFromLocale];
        
    WebViewController *webViewController = [[WebViewController alloc]initWithURLString:url withTitle:title];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    UINavigationBar *navigationBar = [navigationController navigationBar];
    navigationBar.tintColor = [UIColor blackColor];
    [self presentModalViewController:navigationController animated:YES];
    [webViewController release];
    [navigationController release];    
}




/**
 loads the Webview
 */
- (IBAction)loadWebView:(id)sender{
//    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
	NSString *urlAddress = NSLocalizedString(@"BannerURL", @"BannerURL");
    /*
    if ([language isEqualToString:@"de"]) {
        urlAddress = @"http://www.aidshilfe.de";
    }
     */
    WebViewController *webViewController = [[WebViewController alloc]initWithURLString:urlAddress withTitle:NSLocalizedString(@"POZ Magazine", @"POZ Magazine")];
        
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    UINavigationBar *navigationBar = [navigationController navigationBar];
    navigationBar.tintColor = [UIColor blackColor];
    [self presentModalViewController:navigationController animated:YES];
    [webViewController release];
    [navigationController release];
}

- (IBAction)loadAd:(id)sender{
	NSString *urlAddress = NSLocalizedString(@"AdURL", @"AdURL");
    /*
     if ([language isEqualToString:@"de"]) {
     urlAddress = @"http://www.aidshilfe.de";
     }
     */
    WebViewController *webViewController = [[WebViewController alloc]initWithURLString:urlAddress withTitle:NSLocalizedString(@"Gaydar.Net", @"Gaydar.net")];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    UINavigationBar *navigationBar = [navigationController navigationBar];
    navigationBar.tintColor = [UIColor blackColor];
    [self presentModalViewController:navigationController animated:YES];
    [webViewController release];
    [navigationController release];
}



/**
 the master record is set up at the first time the application is launched.
 the record contains the relationships to results and medications, which will be added to the master record.
 */
- (void)setUpMasterRecord{
#ifdef APPDEBUG
	NSLog(@"iStayHealthyTableViewController:setUpMasterRecord ENTERING");
#endif

	NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
	NSManagedObject *newRecord = [NSEntityDescription insertNewObjectForEntityForName:@"iStayHealthyRecord" inManagedObjectContext:context];
	[newRecord setValue:@"Master Record" forKey:@"Name"];
#ifdef APPDEBUG
	NSLog(@"iStayHealthyTableViewController:setUpMasterRecord before saving data");
#endif
	NSError *error = nil;
	if (![newRecord.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}

#ifdef APPDEBUG
	NSLog(@"iStayHealthyTableViewController:setUpMasterRecord LEAVING");
#endif
}

/**
 setting up the view just before it appears. Sanity check to see we got all the data we need.
 It also checks whether the master record is created - like viewDidLoad. This may be a bit of an overkill,
 but I decided to be on the safe side.
 @animated
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	NSArray *objects = [self.fetchedResultsController fetchedObjects];
	if (0 == [objects count]) {
#ifdef APPDEBUG		
		NSLog(@"iStayHealthyTableViewController::viewWillAppear no master record yet");
#endif
		[self setUpMasterRecord];
	}
	self.masterRecord = (iStayHealthyRecord *)[objects objectAtIndex:0];
    [self setUpData];
}



#pragma mark -
#pragma mark Table view data source
/**
 will be set by subclass
 @tableView
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 0;
}

/**
 will be set by subclass
 @tableView
 @section
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 0;
}

/**
 will be set by subclass
 @tableView
 @indexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    return cell;
}



#pragma mark -
#pragma mark Table view delegate

/**
 this handles the fetching of the objects
 @return NSFetchedResultsController
 */
- (NSFetchedResultsController *)fetchedResultsController{
	if (fetchedResultsController_ != nil) {
		return fetchedResultsController_;
	}
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	iStayHealthyAppDelegate *appDelegate = (iStayHealthyAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = appDelegate.managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"iStayHealthyRecord" inManagedObjectContext:context];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"Name" ascending:YES];
	NSArray *allDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:allDescriptors];	
	[request setEntity:entity];
	
	NSFetchedResultsController *tmpFetchController = [[NSFetchedResultsController alloc]
													  initWithFetchRequest:request 
													  managedObjectContext:context 
													  sectionNameKeyPath:nil 
													  cacheName:nil];
	tmpFetchController.delegate = self;
	fetchedResultsController_ = tmpFetchController;
	
	[request release];
    [allDescriptors release];
    [sortDescriptor release];
	return fetchedResultsController_;
	
}	

/**
 set up the data tables
 */
- (void)setUpData{
	NSArray *objects = [self.fetchedResultsController fetchedObjects];
	self.masterRecord = (iStayHealthyRecord *)[objects objectAtIndex:0];
        
    /* Results in chronological/reverse order */
	NSSet *results = self.masterRecord.results;
	if (0 != [results count]) {
		self.allResults = [NSArray arrayByOrderingSet:results byKey:@"ResultsDate" ascending:YES reverseOrder:NO];
		self.allResultsInReverseOrder = [NSArray arrayByOrderingSet:results byKey:@"ResultsDate" ascending:YES reverseOrder:YES];
	}
    else{
        self.allResults = (NSArray *)results;
        self.allResultsInReverseOrder = (NSArray *)results;
    }
        
    /* HIV Meds in chronological oder */
	NSSet *hivmeds = self.masterRecord.medications;
	if (0 != [hivmeds count]) {
		self.allMeds = [NSArray arrayByOrderingSet:hivmeds byKey:@"StartDate" ascending:YES reverseOrder:NO];
	}
    else
        self.allMeds = (NSArray *)hivmeds;
    
    /* Missed HIV Meds in chronological oder */
    NSSet *missedMeds = self.masterRecord.missedMedications;
    if (0 != [missedMeds count]) {
        self.allMissedMeds = [NSArray arrayByOrderingSet:missedMeds byKey:@"MissedDate" ascending:YES reverseOrder:NO];
    }
    else
        self.allMissedMeds = (NSArray *)missedMeds;
    
    /* OtherMedication ordered by name */
    NSSet *meds = self.masterRecord.otherMedications;
    if (0 != [meds count]) {
        self.allPills = [NSArray arrayByOrderingSet:meds byKey:@"Name" ascending:YES reverseOrder:NO];
    }
    else {
        self.allPills = (NSArray *)meds;
    }
    
    /* Procedures */
    NSSet *procSet = self.masterRecord.procedures;
    if(0 != [procSet count]){
        self.allProcedures = [NSArray arrayByOrderingSet:procSet byKey:@"Name" ascending:YES reverseOrder:NO];
    }
    else{
        self.allProcedures = (NSArray *)procSet;
    }

    //arrays that need no ordering
    NSSet *contactSet = self.masterRecord.contacts;
    if(0 != [contactSet count]){
        self.allContacts = [NSArray arrayByOrderingSet:contactSet byKey:@"ClinicName" ascending:YES reverseOrder:NO];
    }
    else{
        self.allContacts = (NSArray *)self.masterRecord.contacts;
    }
    
    NSSet *effectSet = self.masterRecord.sideeffects;
    if(0 != [effectSet count]){
        self.allSideEffects = [NSArray arrayByOrderingSet:effectSet byKey:@"SideEffect" ascending:YES reverseOrder:NO];
    }
    else{
        self.allSideEffects = (NSArray *)self.masterRecord.sideeffects;
    }
#ifdef APPDEBUG
    NSLog(@"iStayHealthyTableViewController::setUpData hivMeds %d ",[self.allMeds count]);
#endif
}
/**
 notified when changes to the database
 @controller
 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
#ifdef APPDEBUG
    NSLog(@"iStayHealthyTableViewController::controllerDidChangeContent");
#endif
    [self setUpData];
	[self.tableView reloadData];
}

#pragma mark - Device Orientation

/** 
 allow device rotation
 @interfaceOrientation the actual orientation of the device
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
}


/**
 notifies the app that the orientation changed
 @notification
 */
- (void)orientationChanged:(NSNotification *)notification
{
    [self performSelector:@selector(updateLandscapeView) withObject:nil afterDelay:0];
}

/**
 does the device rotation
 */
- (void)updateLandscapeView
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (deviceOrientation == UIDeviceOrientationLandscapeLeft && !isShowingLandscapeView)
	{
        [self presentModalViewController:self.landscapeController animated:YES];
        isShowingLandscapeView = YES;
    }
    else if(deviceOrientation == UIDeviceOrientationLandscapeRight && !isShowingLandscapeView){
        [self presentModalViewController:self.landscapeController animated:YES];
        isShowingLandscapeView = YES;
        
    }
	else if (deviceOrientation == UIDeviceOrientationPortrait && isShowingLandscapeView)
	{
        [self dismissModalViewControllerAnimated:YES];
        isShowingLandscapeView = NO;
    }    
    else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown && isShowingLandscapeView){
        [self dismissModalViewControllerAnimated:YES];
        isShowingLandscapeView = NO;        
    }
}


#pragma mark -
#pragma mark Memory management
/**
 handle memory warnings
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
/**
 unload view
 */
- (void)viewDidUnload {
    self.masterRecord = nil;
    self.landscapeController = nil;
    self.allContacts = nil;
    self.allMeds = nil;
    self.allMissedMeds = nil;
    self.allPills = nil;
    self.allResults = nil;
    self.allResultsInReverseOrder = nil;
    self.allSideEffects = nil;
    self.allProcedures = nil;
    self.headerView = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
	[super viewDidUnload];
}

/**
 dealloc
 */
- (void)dealloc {
	[fetchedResultsController_ release];
    self.masterRecord = nil;
    self.landscapeController = nil;
    self.allContacts = nil;
    self.allMeds = nil;
    self.allMissedMeds = nil;
    self.allPills = nil;
    self.allResults = nil;
    self.allResultsInReverseOrder = nil;
    self.allSideEffects = nil;
    self.allProcedures = nil;
    self.headerView = nil;
    [super dealloc];
}


@end

