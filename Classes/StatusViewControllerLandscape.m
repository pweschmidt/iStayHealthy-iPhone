//
//  StatusViewControllerLandscape.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StatusViewControllerLandscape.h"
#import "iStayHealthyAppDelegate.h"
#import "ChartSettings.h"
#import "HealthChartsView.h"
#import "HealthChartsViewLandscape.h"
#import "iStayHealthyRecord.h"
#import "NSArray-Set.h"
#import "ChartEvents.h"

@implementation StatusViewControllerLandscape
@synthesize chartView=_chartView;
@synthesize allResults = _allResults;
@synthesize allMeds = _allMeds;
@synthesize masterRecord = _masterRecord;
@synthesize allMissedMeds = _allMissedMeds;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize events;
/**
 inits the ViewController
 @nibNameOrNil - the NIB file name for the landscape controller
 @nibBundleOrNil - the bundle
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
#ifdef APPDEBUG	
	NSLog(@"StatusViewControllerLandscape:initWithNibName");
#endif
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
	{
        self.wantsFullScreenLayout = YES; // we want to overlap the status bar.        
		self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        ChartEvents *tmpEvents = [[ChartEvents alloc]init];
        self.events = tmpEvents;
        [tmpEvents release];
    }
    return self;
}

/**
 loaded once. sets up the landscape chart view
 */
- (void)viewDidLoad{
	[super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:@"RefetchAllDatabaseData" object:[[UIApplication sharedApplication] delegate]];
    
#ifdef APPDEBUG	
	NSLog(@"StatusViewControllerLandscape:viewDidLoad reset chart");
#endif
	CGRect frame = CGRectMake(0.0, 20.0, 480.0, 300.0);
    HealthChartsViewLandscape *chart = [[HealthChartsViewLandscape alloc]initWithFrame:frame];
    //	ChartViewLandscape *chart = [[ChartViewLandscape alloc]initWithFrame:frame];
    [self.view addSubview:chart];
    self.chartView = chart;
    self.chartView.events = self.events;
    [chart release];
    
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
}

/**
 called each time this view is shown
 @animated
 */
- (void)viewWillAppear:(BOOL)animated
{
#ifdef APPDEBUG	
	NSLog(@"StatusViewControllerLandscape:viewWillAppear");
#endif
    [super viewWillAppear:animated];
    [self setUpData];
}



/**
 called each time we move away from this view
 @animated
 */
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    [[UIApplication sharedApplication] setStatusBarStyle:oldStatusBarStyle animated:NO];    
}

/**
 */
- (void)setUpData{
#ifdef APPDEBUG	
	NSLog(@"StatusViewControllerLandscape:setUpData");
#endif
	NSArray *objects = [self.fetchedResultsController fetchedObjects];
	
	self.masterRecord = (iStayHealthyRecord *)[objects objectAtIndex:0];
    
	NSSet *results = self.masterRecord.results;
	NSSet *meds = self.masterRecord.medications;
    NSSet *missedMeds = self.masterRecord.missedMedications;
    if (0 < [self.events.allChartEvents count]) {
        [self.events.allChartEvents removeAllObjects];
    }
    
	if (0 != [results count]) {
		self.allResults = [NSArray arrayByOrderingSet:results byKey:@"ResultsDate" ascending:YES reverseOrder:NO];
#ifdef APPDEBUG	
        NSLog(@"StatusViewControllerLandscape:setUpData Results array has %d entries",[results count]);
#endif
	}
	else {
#ifdef APPDEBUG	
        NSLog(@"StatusViewControllerLandscape:setUpData Results array is empty. Why?");
#endif
		self.allResults = (NSMutableArray *)results;
	}
	if (0 != [meds count]) {
		self.allMeds = [NSArray arrayByOrderingSet:meds byKey:@"StartDate" ascending:YES reverseOrder:NO];
	}
	else {
		self.allMeds = (NSMutableArray *)meds;
	}
    if (0 != [missedMeds count]) {
        self.allMissedMeds = [NSArray arrayByOrderingSet:missedMeds byKey:@"MissedDate" ascending:YES reverseOrder:NO];
    }
    else
        self.allMissedMeds = (NSMutableArray *)masterRecord.missedMedications;
    
    [self.events loadResult:self.allResults];
    [self.events loadMedication:self.allMeds];
    [self.events loadMissedMedication:self.allMissedMeds];
    [self.events sortEventsAscending:YES];
    
}

/**
 called when being notifed about any changes
 */
- (void)reloadData:(NSNotification *)note{
    if (0 < [self.events.allChartEvents count]) {
        [self.events.allChartEvents removeAllObjects];
    }
    [self setUpData];
	[chartView setNeedsDisplay];
}




/**
 only landscape mode allowed
 @interfaceOrientation
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

/**
 fetchedResultsController
 @return NSFetchedResultsController
 */
- (NSFetchedResultsController *)fetchedResultsController{
	if (_fetchedResultsController != nil) {
		return _fetchedResultsController;
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
	_fetchedResultsController = tmpFetchController;
	
	[request release];
    [allDescriptors release];
    [sortDescriptor release];
	return _fetchedResultsController;
	
}	

/**
 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{	
#ifdef APPDEBUG	
	NSLog(@"---> in landscape mode. data changed");
#endif
	NSArray *objects = [self.fetchedResultsController fetchedObjects];
	self.masterRecord = (iStayHealthyRecord *)[objects objectAtIndex:0];
	[chartView setNeedsDisplay];
}

#pragma mark -
#pragma mark memory stuff
/**
 handle memory warning
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 unload
 */
- (void)viewDidUnload {
    [super viewDidUnload];
}

/**
 dealloc
 */
- (void)dealloc {
	[allMeds release];
	[allResults release];
    [allMissedMeds release];
    self.chartView = nil;
//	[chartView release];
	[masterRecord release];
//    self.fetchedResultsController = nil;
	[_fetchedResultsController release];
    [events release];
    [super dealloc];
}


@end
