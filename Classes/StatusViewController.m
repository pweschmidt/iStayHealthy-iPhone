//
//  StatusViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 04/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StatusViewController.h"
#import "StatusViewControllerLandscape.h"
#import "ChartSettings.h"
#import "HealthChartsView.h"
#import "HealthChartsViewPortrait.h"
#import "iStayHealthyRecord.h"
#import "Results.h"
#import "Medication.h"
#import "NSArray-Set.h"
#import "GeneralSettings.h"
#import "StatusViewCell.h"
#import "InfoDetailTableViewController.h"
#import "SettingsDetailViewController.h"
#import "ChartEvents.h"
#import "WebViewController.h"

@implementation StatusViewController
@synthesize allResults, allMeds, allMissedMeds, chartView/*, landscapeController*/;
@synthesize cd4StatusCell, cd4PercentCell, viralLoadStatusCell;
@synthesize events/*, headerView*/;

#pragma mark -
#pragma mark View lifecycle

/**
 loaded at startup time
 */
- (void)viewDidLoad {
    [super viewDidLoad];
#ifdef APPDEBUG	
	NSLog(@"StatusViewController::viewDidLoad ENTERING");
#endif
	StatusViewControllerLandscape *landscape = [[StatusViewControllerLandscape alloc]initWithNibName:@"StatusViewControllerLandscape" bundle:nil];
	self.landscapeController = landscape;
	[landscape release];
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:)
												 name:UIDeviceOrientationDidChangeNotification object:nil];
	UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[infoButton addTarget:self action:@selector(showInfoView:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showSettingsView:)];
    
    
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    self.navigationItem.leftBarButtonItem = actionButton;
	self.events = [[ChartEvents alloc]init];


    CGRect pozFrame = CGRectMake(CGRectGetMinX(headerView.bounds)+20, CGRectGetMinY(headerView.bounds)+2, 47.0, 30.0);
    UIButton *pozButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [pozButton setFrame:pozFrame];
    [pozButton setBackgroundImage:[UIImage imageNamed:@"poz75.jpg"] forState:UIControlStateNormal];
    [pozButton addTarget:self action:@selector(loadWebView:) forControlEvents:UIControlEventTouchUpInside];
    CGRect pozLabelFrame = CGRectMake(CGRectGetMinX(headerView.bounds)+75, CGRectGetMinY(headerView.bounds)+2, 200.0, 30.0);
    UILabel *pozLabel = [[UILabel alloc]initWithFrame:pozLabelFrame];
    pozLabel.backgroundColor = [UIColor clearColor];
    pozLabel.textColor = DARK_YELLOW;
    pozLabel.font = [UIFont boldSystemFontOfSize:12.0];
    pozLabel.textAlignment = UITextAlignmentCenter;
    pozLabel.text = @"www.poz.com Healthy, Life & HIV";
    [headerView addSubview:pozButton];
    [headerView addSubview:pozLabel];
 /*   
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (navBar) {
        CGRect toolsButtonFrame = CGRectMake(CGRectGetMinX(navBar.bounds) + 10.0, CGRectGetMinY(navBar.bounds)+7.0, 29.0, 29.0);
        UIButton* toolsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [toolsButton setFrame:toolsButtonFrame];
        [toolsButton setBackgroundImage:[UIImage imageNamed:@"tools.png"] forState:UIControlStateNormal];
        [toolsButton setBackgroundImage:[UIImage imageNamed:@"tools-highlighted.png"] forState:UIControlStateHighlighted];
        [toolsButton addTarget:self action:@selector(showSettingsView:) forControlEvents:UIControlEventTouchUpInside];            
        [navBar addSubview:toolsButton];        
    }
  */
    [infoButton release];
}

/**
 loads the info viewer with short explanations on CD4 counts and Viral Loads
 @id sender
 */
- (void) showInfoView:(id)sender{
	InfoDetailTableViewController *infoViewController = [[InfoDetailTableViewController alloc] initWithNibName:@"InfoDetailTableViewController" bundle:nil];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:infoViewController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
    [self presentModalViewController:navigationController animated:YES];
	[infoViewController release];
    [navigationController release];
}


/**
 loads the settings view
 @id sender
 */
- (void) showSettingsView:(id)sender{
    SettingsDetailViewController *settingsViewController = [[SettingsDetailViewController alloc] initWithNibName:@"SettingsDetailViewController" bundle:nil];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
    [self.navigationController presentModalViewController:navigationController animated:YES];
    [navigationController release];    
}



/**
 viewWillAppear called each time this view controller is shown. At this stage we make sure we reload the arrays
 that are needed to display the cell content and charts
 @animated
 */
- (void)viewWillAppear:(BOOL)animated {
#ifdef APPDEBUG	
	NSLog(@"**** StatusViewController::viewWillAppear ENTERING");
#endif
    [super viewWillAppear:animated];
	NSSet *results = masterRecord.results;
	NSSet *meds = masterRecord.medications;
    NSSet *missedMeds = masterRecord.missedMedications;
    if (0 < [self.events.allChartEvents count]) {
        [self.events.allChartEvents removeAllObjects];
    }


	if (0 != [results count]) {
		self.allResults = [NSArray arrayByOrderingSet:results byKey:@"ResultsDate" ascending:YES reverseOrder:NO];
	}
    else
        self.allResults = (NSMutableArray *)results;

	if (0 != [meds count]) {
		self.allMeds = [NSArray arrayByOrderingSet:meds byKey:@"StartDate" ascending:YES reverseOrder:NO];
	}
    else
        self.allMeds = (NSMutableArray *)meds;
    
    if (0 != [missedMeds count]) {
        self.allMissedMeds = [NSArray arrayByOrderingSet:missedMeds byKey:@"MissedDate" ascending:YES reverseOrder:NO];
    }
    else
        self.allMissedMeds = (NSMutableArray *)missedMeds;
    
    
    [self.events loadResult:self.allResults];
    [self.events loadMedication:self.allMeds];
    [self.events loadMissedMedication:self.allMissedMeds];
    [self.events sortEventsAscending:YES];
	[self.tableView reloadData];
#ifdef APPDEBUG	
	NSLog(@"**** StatusViewController::viewWillAppear LEAVING");
#endif

}


#pragma mark -
#pragma mark rotation
/** 
 allow device rotation
 @interfaceOrientation the actual orientation of the device
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
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


- (Results *)latestResult:(NSString *)type{
    if (!self.allResults) {
        return nil;
    }
    if (0 == [self.allResults count]) {
        return nil;
    }
    Results *result = nil;
    BOOL isFound = NO;
    int limit = [self.allResults count] -1;
    for (int i = limit; i >= 0; --i) {
        Results *current = (Results *)[self.allResults objectAtIndex:i];
        if (!isFound) {
            if ([type isEqualToString:@"CD4Count"]) {
                if (0 < [current.CD4 intValue]) {
                    result = current;
                    isFound = YES;
                }
            }
            if ([type isEqualToString:@"CD4Percent"]) {
                if (0.0 < [current.CD4Percent floatValue]) {
                    result = current;
                    isFound = YES;
                }
            }
            if ([type isEqualToString:@"ViralLoad"]) {
                if (0 <= [current.ViralLoad intValue]) {
                    result = current;
                    isFound = YES;
                }
            }            
        }
    }
    return result;
}

- (Results *)previousResult:(NSString *)type{
    if (!self.allResults) {
        return nil;
    }
    if (2 > [self.allResults count]) {
        return nil;
    }
    Results *result = nil;
    BOOL isFound = NO;
    int limit = [self.allResults count] -1;
    int count = 0;
    for (int i = limit; i >= 0; --i) {
        Results *previous = (Results *)[self.allResults objectAtIndex:i];
        if (!isFound) {
            if ([type isEqualToString:@"CD4Count"]) {
                if (0 < [previous.CD4 intValue] && 1 == count) {
                    result = previous;
                    isFound = YES;
                }
                else
                    ++count;
            }
            if ([type isEqualToString:@"CD4Percent"]) {
                if (0.0 < [previous.CD4Percent floatValue] && 1 == count) {
                    result = previous;
                    isFound = YES;
                }
                else
                    ++count;
            }
            if ([type isEqualToString:@"ViralLoad"]) {
                if (0 <= [previous.ViralLoad intValue] && 1 == count) {
                    result = previous;
                    isFound = YES;
                }
                else
                    ++count;
            }
        }
    }
    
    return result;
    
}

#pragma mark -
#pragma mark Table view data source
/**
 2 sections. section 0 contains 2 status cells (CD4/Viral Load), section 1 contains 1 cell with the charts
 @tableView 
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

/**
 2 row in section 0, 1 row in section 1
 @tableView
 @section
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (0 == section) {
		return 3;
	}
    return 1;
}

/**
 for the results cells we use a height of 50 - for the chart we use a height of 230
 @tableView
 @indexPath
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if (0 == indexPath.section) {
		return TEXTCELLHEIGHT;
	}
	else {
		return CHARTCELLHEIGHT;
	}
}

/**
 setup the CD4 status cell
 */
- (void)configureCD4Cell{
	self.cd4StatusCell.cellNameLabel.text = NSLocalizedString(@"CD4 Count", nil);
	self.cd4StatusCell.cellNameLabel.textColor = DARK_YELLOW;

	if (!self.allResults) {
#ifdef APPDEBUG	
		NSLog(@"StatusViewController: configureCD4Cell allResults is nil");
#endif
		return;
	}
	NSUInteger count = [self.allResults count];

#ifdef APPDEBUG	
	NSLog(@"StatusViewController: configureCD4Cell number of results %d",count);
#endif

	if (0 == count) {
		self.cd4StatusCell.resultLabel.text = NSLocalizedString(@"No results", nil);
		self.cd4StatusCell.resultLabel.textColor = [UIColor lightGrayColor];
		self.cd4StatusCell.dateLabel.text = @"";
		self.cd4StatusCell.changeLabel.text = @"";
		self.cd4StatusCell.upOrDownImage.image = nil;
		return;
	}
    Results *current = [self latestResult:@"CD4Count"];
    if (!current) {
		self.cd4StatusCell.resultLabel.text = NSLocalizedString(@"No results", nil);
		self.cd4StatusCell.resultLabel.textColor = [UIColor lightGrayColor];
		self.cd4StatusCell.dateLabel.text = @"";
		self.cd4StatusCell.changeLabel.text = @"";
		self.cd4StatusCell.upOrDownImage.image = nil;
		return;
    }
//	Results *current = (Results *)[self.allResults lastObject];
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init]autorelease];
	formatter.dateFormat = @"dd MMM YYYY";
//	self.cd4StatusCell.dateLabel.text = [formatter stringFromDate:current.ResultsDate];
	
	int cd4Count = [current.CD4 intValue];
	if (0 < cd4Count) {
        self.cd4StatusCell.resultLabel.text = [NSString stringWithFormat:@"%d",cd4Count];
	}
	
#ifdef APPDEBUG	
	NSLog(@"StatusViewController: after updating the CD4 status cells");
#endif
	Results *previous = [self previousResult:@"CD4Count"];
	if (previous) {
//		previous = (Results *)[self.allResults objectAtIndex:(count - 2)];
		int previousCD4 = [previous.CD4 intValue];
		if (0 < previousCD4 && 0 < cd4Count) {
			int diff = cd4Count - previousCD4;
			NSString *upPath = [[NSBundle mainBundle] pathForResource:@"upGreenSmall" ofType:@"png"];
			NSString *downPath = [[NSBundle mainBundle] pathForResource:@"downRedSmall" ofType:@"png"];
			self.cd4StatusCell.changeLabel.text = [NSString stringWithFormat:@"%d", diff];
			
			if (0 > diff) {
				self.cd4StatusCell.changeLabel.textColor = DARK_RED;
                self.cd4StatusCell.upOrDownImage.image = [UIImage imageWithContentsOfFile:downPath];
			}
			else if (0 < diff){
				self.cd4StatusCell.changeLabel.textColor = DARK_GREEN;
                self.cd4StatusCell.upOrDownImage.image = [UIImage imageWithContentsOfFile:upPath];
			}
            else
                self.cd4StatusCell.changeLabel.textColor = [UIColor lightGrayColor];


		}
	}
	else {
		self.cd4StatusCell.dateLabel.text = @"";
		self.cd4StatusCell.changeLabel.text = @"";
		self.cd4StatusCell.upOrDownImage.image = nil;
	}

	
}

- (void)configureCD4PercentCell{
	self.cd4PercentCell.cellNameLabel.text = NSLocalizedString(@"CD4 %", nil);
	self.cd4PercentCell.cellNameLabel.textColor = DARK_YELLOW;
    
	if (!self.allResults) {
#ifdef APPDEBUG	
		NSLog(@"StatusViewController: configureCD4PercentCell allResults is nil");
#endif
		return;
	}
	NSUInteger count = [self.allResults count];
    
#ifdef APPDEBUG	
	NSLog(@"StatusViewController: configureCD4PercentCell number of results %d",count);
#endif
    
	if (0 == count) {
		self.cd4PercentCell.resultLabel.text = NSLocalizedString(@"No results", nil);
		self.cd4PercentCell.resultLabel.textColor = [UIColor lightGrayColor];
		self.cd4PercentCell.dateLabel.text = @"";
		self.cd4PercentCell.changeLabel.text = @"";
		self.cd4PercentCell.upOrDownImage.image = nil;
		return;
	}
    Results *current = [self latestResult:@"CD4Percent"];
    if (!current) {
		self.cd4PercentCell.resultLabel.text = NSLocalizedString(@"No results", nil);
		self.cd4PercentCell.resultLabel.textColor = [UIColor lightGrayColor];
		self.cd4PercentCell.dateLabel.text = @"";
		self.cd4PercentCell.changeLabel.text = @"";
		self.cd4PercentCell.upOrDownImage.image = nil;
		return;
    }
//	Results *current = (Results *)[self.allResults lastObject];
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init]autorelease];
	formatter.dateFormat = @"dd MMM YYYY";
//	self.cd4PercentCell.dateLabel.text = [formatter stringFromDate:current.ResultsDate];
	
	float cd4Percent = [current.CD4Percent floatValue];
	if (0.0 < cd4Percent) {
        self.cd4PercentCell.resultLabel.text = [NSString stringWithFormat:@"%2.1f%%",[current.CD4Percent floatValue]];
	}
	
#ifdef APPDEBUG	
	NSLog(@"StatusViewController: after updating the CD4 status cells");
#endif
	Results *previous = [self previousResult:@"CD4Percent"];
	if (previous) {
//		previous = (Results *)[self.allResults objectAtIndex:(count - 2)];
		float previousCD4Percent = [previous.CD4Percent floatValue];
		if (0.0 < previousCD4Percent && 0 < cd4Percent) {
			float diff = cd4Percent - previousCD4Percent;
			NSString *upPath = [[NSBundle mainBundle] pathForResource:@"upGreenSmall" ofType:@"png"];
			NSString *downPath = [[NSBundle mainBundle] pathForResource:@"downRedSmall" ofType:@"png"];
			self.cd4PercentCell.changeLabel.text = [NSString stringWithFormat:@"%2.1f%%", diff];
			
			if (0.0 > diff) {
				self.cd4PercentCell.changeLabel.textColor = DARK_RED;
                self.cd4PercentCell.upOrDownImage.image = [UIImage imageWithContentsOfFile:downPath];
			}
			else if (0.0 < diff){
				self.cd4PercentCell.changeLabel.textColor = DARK_GREEN;
                self.cd4PercentCell.upOrDownImage.image = [UIImage imageWithContentsOfFile:upPath];
			}
            else
                self.cd4PercentCell.changeLabel.textColor = [UIColor lightGrayColor];
            
            
		}
	}
	else {
		self.cd4PercentCell.dateLabel.text = @"";
		self.cd4PercentCell.changeLabel.text = @"";
		self.cd4PercentCell.upOrDownImage.image = nil;
	}
    
    
}

/**
 setup the viral load status cell
 */
- (void)configureViralLoadCell{
#ifdef APPDEBUG	
	NSLog(@"StatusViewController::configureViralLoadCell ENTERING");
#endif
	self.viralLoadStatusCell.cellNameLabel.text = NSLocalizedString(@"Viral Load", nil);
	self.viralLoadStatusCell.cellNameLabel.textColor = DARK_BLUE;
	if (!self.allResults) {
		return;
	}
	NSUInteger count = [self.allResults count];
	if (0 == count) {
#ifdef APPDEBUG	
		NSLog(@"StatusViewController: configureViralLoadCell number of results %d",count);
#endif
		self.viralLoadStatusCell.resultLabel.text = NSLocalizedString(@"No results", nil);
		self.viralLoadStatusCell.resultLabel.textColor = [UIColor lightGrayColor];
		self.viralLoadStatusCell.changeLabel.text = @"";
		self.viralLoadStatusCell.dateLabel.text = @"";
		self.viralLoadStatusCell.upOrDownImage.image = nil;
		return;
	}
    Results *current = [self latestResult:@"ViralLoad"];
    if (!current) {
		self.viralLoadStatusCell.resultLabel.text = NSLocalizedString(@"No results", nil);
		self.viralLoadStatusCell.resultLabel.textColor = [UIColor lightGrayColor];
		self.viralLoadStatusCell.changeLabel.text = @"";
		self.viralLoadStatusCell.dateLabel.text = @"";
		self.viralLoadStatusCell.upOrDownImage.image = nil;
		return;
    }
//	Results *current = (Results *)[self.allResults lastObject];
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init]autorelease];
	formatter.dateFormat = @"dd MMM YYYY";
//	self.viralLoadStatusCell.dateLabel.text = [formatter stringFromDate:current.ResultsDate];
	int vlCount = [current.ViralLoad intValue];
    
	if (10 < vlCount) {
		self.viralLoadStatusCell.resultLabel.text = [NSString stringWithFormat:@"%d",vlCount];
	}
	else if(0 <= vlCount && 10 >= vlCount){
		self.viralLoadStatusCell.resultLabel.text = NSLocalizedString(@"undetectable", nil);
	}
    else
        self.viralLoadStatusCell.resultLabel.text = NSLocalizedString(@"n/a", nil);

	
	Results *previous = [self previousResult:@"ViralLoad"];
	if (previous) {
//		previous = (Results *)[self.allResults objectAtIndex:(count - 2)];
		int previousVL = [previous.ViralLoad intValue];
		if (10 < vlCount && 10 < previousVL) {
			int diff = vlCount - previousVL;
			NSString *upPath = [[NSBundle mainBundle] pathForResource:@"upRedSmall" ofType:@"png"];
			NSString *downPath = [[NSBundle mainBundle] pathForResource:@"downGreenSmall" ofType:@"png"];
			self.viralLoadStatusCell.changeLabel.text = [NSString stringWithFormat:@"%d", diff];

			if (0 > diff) {
				self.viralLoadStatusCell.changeLabel.textColor = DARK_GREEN;
                self.viralLoadStatusCell.upOrDownImage.image = [UIImage imageWithContentsOfFile:downPath];
			}
			if (0 < diff){
				self.viralLoadStatusCell.changeLabel.textColor = DARK_RED;
                self.viralLoadStatusCell.upOrDownImage.image = [UIImage imageWithContentsOfFile:upPath];
			}
            if (0 == diff) {
				self.viralLoadStatusCell.changeLabel.textColor = [UIColor lightGrayColor];
                self.viralLoadStatusCell.upOrDownImage.image = nil;
            }
		}
	}
	else {
		self.viralLoadStatusCell.changeLabel.text = @"";
		self.viralLoadStatusCell.dateLabel.text = @"";
		self.viralLoadStatusCell.upOrDownImage.image = nil;
	}
#ifdef APPDEBUG	
	NSLog(@"StatusViewController::configureViralLoadCell LEAVING");
#endif

}


/**
 sets up the cells for this view
 @tableView
 @indexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    
	if (0 == indexPath.section) {
		if (0 == indexPath.row) {
#ifdef APPDEBUG	
            NSLog(@"StatusViewController: cellForRowAtIndexPath loading CD4 status cell");
#endif
            StatusViewCell *cell = (StatusViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (nil == cell) {
                self.cd4StatusCell = [[[StatusViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            cell = self.cd4StatusCell;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [self configureCD4Cell];
            return (UITableViewCell *)cell;
        } 
        else if( 1 == indexPath.row){
            StatusViewCell *cell = (StatusViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (nil == cell) {
                self.cd4PercentCell = [[[StatusViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            cell = self.cd4PercentCell;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [self configureCD4PercentCell];
            return (UITableViewCell *)cell;            
        }
        else{
#ifdef APPDEBUG	
            NSLog(@"StatusViewController: cellForRowAtIndexPath loading Viral Load status cell");
#endif
            StatusViewCell *cell = (StatusViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (nil == cell) {
                self.viralLoadStatusCell = [[[StatusViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            cell = self.viralLoadStatusCell;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [self configureViralLoadCell];					
            return (UITableViewCell *)cell;
		}
	}
	else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (nil == cell) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		cell.backgroundColor = BRIGHT_BACKGROUND;			
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
#ifdef APPDEBUG	
        NSLog(@"StatusViewController: cellForRowAtIndexPath allocating HIVChartView");
#endif
/* 		
		ChartView *chart = [[ChartViewPortrait alloc] initWithFrame:CGRectMake(CGRectGetMinX(cell.bounds)+MARGINLEFT, CGRectGetMinY(cell.bounds), CGRectGetWidth(cell.bounds) - MARGINLEFT*2.5, CHARTCELLHEIGHT)];
        chart.allResults = self.allResults;
        chart.allMeds = self.allMeds;
 */
        CGRect frame = CGRectMake(CGRectGetMinX(cell.bounds)+MARGINLEFT/2, CGRectGetMinY(cell.bounds), CGRectGetWidth(cell.bounds) - MARGINLEFT*1.5, CHARTCELLHEIGHT);
        HealthChartsView *chart = [[HealthChartsViewPortrait alloc] initWithFrame:frame];
        chart.events = self.events;

		[cell.contentView addSubview:chart];
#ifdef APPDEBUG	
        NSLog(@"StatusViewController: cellForRowAtIndexPath added Subview HIVChartView");
#endif
		self.chartView = chart;
		[chart release];
#ifdef APPDEBUG	
        NSLog(@"StatusViewController: cellForRowAtIndexPath released chart  HIVChartView");
#endif
        return cell;
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
 */
- (void)viewDidUnload {
	[super viewDidUnload];
}

/**
 dealloc
 */
- (void)dealloc {
	[allResults release];
	[allMeds release];
    [allMissedMeds release];
	[chartView release];
	[cd4StatusCell release];
    [cd4PercentCell release];
	[viralLoadStatusCell release];
    [events release];
    [super dealloc];
}


@end

