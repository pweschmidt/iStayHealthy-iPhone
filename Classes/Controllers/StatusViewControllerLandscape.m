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
#import "SQLDataTableController.h"
#import "NSArray-Set.h"
#import "ChartEvents.h"
#import <QuartzCore/QuartzCore.h>

@interface StatusViewControllerLandscape ()
@property (nonatomic, strong) SQLDataTableController *resultsController;
@property (nonatomic, strong) SQLDataTableController *medsController;
@property (nonatomic, strong) SQLDataTableController *missedController;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, assign) BOOL hasReloadedData;
@property UIStatusBarStyle oldStatusBarStyle;
@property BOOL hasNoResults;
@property BOOL hasNoMedication;
@property BOOL hasNoMissedDates;
@property (nonatomic, strong) HealthChartsViewLandscape *chartView;
@property (nonatomic, strong) NSArray *allResults;
@property (nonatomic, strong) NSArray *allMeds;
@property (nonatomic, strong) NSArray *allMissedMeds;
@property (nonatomic, strong) ChartEvents *events;
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicator;
- (void)setUpData;
@end

@implementation StatusViewControllerLandscape
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
    }
    return self;
}

/**
 loaded once. sets up the landscape chart view
 */
- (void)viewDidLoad
{
	[super viewDidLoad];
    [self setUpData];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData:)
                                                 name:@"RefetchAllDatabaseData"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(start)
                                                 name:@"startLoading"
                                               object:nil];
    
    CGRect activityFrame = CGRectMake(self.view.bounds.size.width/2 - 70, self.view.bounds.size.height/2-70, 140, 140);
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.activityIndicator.frame = activityFrame;
    self.activityIndicator.layer.cornerRadius = 10;
    CGRect labelFrame = CGRectMake(15, 90, 100, 30);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.text = NSLocalizedString(@"Loading", "Loading");
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 0;
    label.font = [UIFont boldSystemFontOfSize:12];
    [self.activityIndicator addSubview:label];
    [self.view addSubview:self.activityIndicator];
#ifdef APPDEBUG
	NSLog(@"StatusViewControllerLandscape:viewDidLoad reset chart");
#endif
    CGSize size = self.view.bounds.size;
	CGRect frame = CGRectMake(0.0, 20.0, size.height, size.width - 20);
    HealthChartsViewLandscape *chart = [[HealthChartsViewLandscape alloc]initWithFrame:frame];
    [self.view addSubview:chart];
    self.chartView = chart;
    [self.chartView setEvents:self.events];    
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
}




/**
 */
- (void)setUpData
{

	iStayHealthyAppDelegate *appDelegate = (iStayHealthyAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.context = appDelegate.managedObjectContext;
    self.resultsController = [[SQLDataTableController alloc] initForEntityName:@"Results"
                                                                        sortBy:@"ResultsDate"
                                                                   isAscending:NO context:self.context];
    
    self.missedController = [[SQLDataTableController alloc] initForEntityName:@"MissedMedication"
                                                                       sortBy:@"MissedDate"
                                                                  isAscending:NO context:self.context];
    
    self.medsController = [[SQLDataTableController alloc] initForEntityName:@"Medication"
                                                                     sortBy:@"StartDate"
                                                                isAscending:NO context:self.context];
    
    NSArray *results = [self.resultsController entriesForEntity];
    self.allResults = [self.resultsController cleanEntriesForData:results table:kResultsTable];
    NSArray *meds = [self.medsController entriesForEntity];
    self.allMeds = [self.medsController cleanEntriesForData:meds table:kMedicationTable];
    NSArray *missed  = [self.missedController entriesForEntity];
    self.allMissedMeds = [self.missedController cleanEntriesForData:missed table:kMissedMedicationTable];

    if (0 < [self.events.allChartEvents count])
    {
        [self.events.allChartEvents removeAllObjects];
    }
    
    [self.events loadResult:self.allResults];
    [self.events loadMedication:self.allMeds];
    [self.events loadMissedMedication:self.allMissedMeds];
    [self.events sortEventsAscending:YES];
    
}

/**
 called when being notifed about any changes
 */
- (void)reloadData:(NSNotification *)note
{
    if (nil == note)
    {
        return;
    }
    [self.activityIndicator stopAnimating];
    [self setUpData];
    [self.chartView setNeedsDisplay];
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//    }];
}

- (void)start
{
    if (nil != self.activityIndicator)
    {
        if (!self.activityIndicator.isAnimating)
        {
            [self.activityIndicator startAnimating];
        }
    }
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//    }];
}



#ifdef __IPHONE_6_0
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

#endif

#if  defined(__IPHONE_5_1) || defined (__IPHONE_5_0)
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}
#endif

/**
 only landscape mode allowed
 @interfaceOrientation
 */


#pragma mark -
#pragma mark memory stuff
/**
 handle memory warning
 */
- (void)didReceiveMemoryWarning
{
    self.allMeds = nil;
    self.allResults = nil;
    self.allMissedMeds = nil;
    self.chartView = nil;
    self.events = nil;
    self.activityIndicator = nil;
    [super didReceiveMemoryWarning];
}

/**
 unload
 */
#if  defined(__IPHONE_5_1) || defined (__IPHONE_5_0)
- (void)viewDidUnload
{
    self.allMeds = nil;
    self.allResults = nil;
    self.allMissedMeds = nil;
    self.chartView = nil;
    self.events = nil;
    self.activityIndicator = nil;
    [super viewDidUnload];
}
#endif
/**
 dealloc
 */


@end
