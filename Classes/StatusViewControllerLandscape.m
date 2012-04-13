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
 called each time this view is shown
 @animated
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
#ifdef APPDEBUG	
	NSLog(@"StatusViewControllerLandscape:viewWillAppear reset chart");
#endif
	NSArray *objects = [self.fetchedResultsController fetchedObjects];
	
	self.masterRecord = (iStayHealthyRecord *)[objects objectAtIndex:0];
    
	NSSet *results = masterRecord.results;
	NSSet *meds = masterRecord.medications;
    NSSet *missedMeds = masterRecord.missedMedications;
    if (0 < [self.events.allChartEvents count]) {
        [self.events.allChartEvents removeAllObjects];
    }

	if (0 != [results count]) {
#ifdef APPDEBUG	
		NSLog(@"having %d data entries in landscape mode",[results count]);
#endif
		self.allResults = [NSArray arrayByOrderingSet:results byKey:@"ResultsDate" ascending:YES reverseOrder:NO];
	}
	else {
		self.allResults = (NSMutableArray *)results;
#ifdef APPDEBUG	
		NSLog(@"**** StatusViewController count should be %d",[self.allResults count]);
#endif
	}
	if (0 != [meds count]) {
#ifdef APPDEBUG	
		NSLog(@"having %d med entries in landscape mode",[meds count]);
#endif
		self.allMeds = [NSArray arrayByOrderingSet:meds byKey:@"StartDate" ascending:YES reverseOrder:NO];
	}
	else {
		self.allMeds = (NSMutableArray *)meds;
#ifdef APPDEBUG	
		NSLog(@"**** StatusViewController count should be %d",[self.allMeds count]);
#endif
	}
    if (0 != [missedMeds count]) {
        self.allMissedMeds = [NSArray arrayByOrderingSet:missedMeds byKey:@"MissedDate" ascending:YES reverseOrder:NO];
    }
    else
        self.allMissedMeds = (NSMutableArray *)masterRecord.missedMedications;

/*
	chartView.allResults = self.allResults;
	chartView.allMeds = self.allMeds;
*/	
    [self.events loadResult:self.allResults];
    [self.events loadMedication:self.allMeds];
    [self.events loadMissedMedication:self.allMissedMeds];
    [self.events sortEventsAscending:YES];
    
	[chartView setNeedsDisplay];
//    oldStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];
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
 loaded once. sets up the landscape chart view
 */
- (void)viewDidLoad{
	[super viewDidLoad];
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
