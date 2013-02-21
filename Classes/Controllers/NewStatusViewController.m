//
//  NewStatusViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 29/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NewStatusViewController.h"
#import "ChartSettings.h"
#import "HealthChartsView.h"
#import "HealthChartsViewPortrait.h"
#import "iStayHealthyAppDelegate.h"
#import "iStayHealthyRecord.h"
#import "Results.h"
#import "Medication.h"
#import "NSArray-Set.h"
#import "GeneralSettings.h"
#import "InfoDetailTableViewController.h"
#import "SettingsDetailViewController.h"
#import "ChartEvents.h"
#import "WebViewController.h"
#import "SummaryCell.h"
#import "UINavigationBar-Button.h"
#import "SQLDataTableController.h"
#import "Utilities.h"

@interface NewStatusViewController ()
@property (nonatomic, strong) NSNumber *latestCD4Count;
@property (nonatomic, strong) NSNumber *latestCD4Percent;
@property (nonatomic, strong) NSNumber *latestVL;
@property (nonatomic, strong) NSNumber *previousCD4Count;
@property (nonatomic, strong) NSNumber *previousCD4Percent;
@property (nonatomic, strong) NSNumber *previousVL;
@property (nonatomic, strong) NSArray *allResults;
@property (nonatomic, strong) NSArray *allMeds;
@property (nonatomic, strong) NSArray *allMissedMeds;
@property (nonatomic, strong) SQLDataTableController *resultsController;
@property (nonatomic, strong) SQLDataTableController *medsController;
@property (nonatomic, strong) SQLDataTableController *missedController;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, assign) BOOL hasReloadedData;
@property (nonatomic, strong) SummaryCell *cd4Cell;
@property (nonatomic, strong) SummaryCell *cd4PercentCell;
@property (nonatomic, strong) SummaryCell *vlCell;
- (void)configureCD4Cell;
- (void)configureCD4PercentCell;
- (void)configureViralLoadCell;
- (void)setUpData;
- (NSNumber *)latestValueForType:(NSString *)type;
- (NSNumber *)previousValueForType:(NSString *)type;
- (void)getStats;
@end

@implementation NewStatusViewController

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)setUpData
{
	iStayHealthyAppDelegate *appDelegate = (iStayHealthyAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.context = appDelegate.managedObjectContext;
    self.resultsController = [[SQLDataTableController alloc] initForEntityType:kResultsTable
                                                                        sortBy:@"ResultsDate"
                                                                   isAscending:NO context:self.context];
    
    self.missedController = [[SQLDataTableController alloc] initForEntityType:kMissedMedicationTable
                                                                        sortBy:@"MissedDate"
                                                                   isAscending:NO context:self.context];
    
    self.medsController = [[SQLDataTableController alloc] initForEntityType:kMedicationTable
                                                                       sortBy:@"StartDate"
                                                                  isAscending:NO context:self.context];

    /*
     */
    if (0 < [self.events.allChartEvents count])
    {
        [self.events.allChartEvents removeAllObjects];
    }
    self.allResults = [self.resultsController cleanedEntries];
    self.allMeds = [self.medsController cleanedEntries];
    self.allMissedMeds = [self.missedController cleanedEntries];
    [self getStats];
    
    [self.events loadResult:self.allResults];
    [self.events loadMedication:self.allMeds];
    [self.events loadMissedMedication:self.allMissedMeds];
    [self.events sortEventsAscending:YES];
}

#pragma mark - View lifecycle
/**
 viewDidLoad
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"NewStatusViewController:viewDidLoad");
    self.hasReloadedData = NO;
    [self setUpData];

	UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[infoButton addTarget:self action:@selector(showInfoView:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showSettingsView:)];
    
    
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    self.navigationItem.leftBarButtonItem = actionButton;
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (navBar) {
        [navBar addButtonWithTitle:@"Charts" target:self selector:@selector(gotoPOZ)];
    }
    ChartEvents *tmpEvents = [[ChartEvents alloc]init];
	self.events = tmpEvents;
    CGSize size = self.view.bounds.size;
    float cellHeight = size.height * 0.066;
    self.sizeOfSummaryCell = [NSNumber numberWithFloat:cellHeight];
    float chartHeight = size.height * 0.45;
    self.sizeOfChartCell = [NSNumber numberWithFloat:chartHeight];
    
    CGRect frame = [Utilities frameFromSize:self.view.bounds.size];
    self.activityIndicator = [Utilities activityIndicatorViewWithFrame:frame];
    [self.view insertSubview:self.activityIndicator aboveSubview:self.tableView];
}

- (void)reloadData:(NSNotification *)note
{
    NSLog(@"NewStatusViewController:reloadData");
    if (0 < [self.events.allChartEvents count])
    {
        [self.events.allChartEvents removeAllObjects];
    }
    self.hasReloadedData = YES;
    self.allResults = [self.resultsController cleanedEntries];
    self.allMeds = [self.medsController cleanedEntries];
    self.allMissedMeds = [self.missedController cleanedEntries];
    [self getStats];

    [self.activityIndicator stopAnimating];
    [self.events loadResult:self.allResults];
    [self.events loadMedication:self.allMeds];
    [self.events loadMissedMedication:self.allMissedMeds];
    [self.events sortEventsAscending:YES];

    [self.chartView setNeedsDisplay];
    [self configureCD4Cell];
    [self configureCD4PercentCell];
    [self configureViralLoadCell];
}

- (void)start
{
    if (![self.activityIndicator isAnimating] && !self.hasReloadedData)
    {
        [self.activityIndicator startAnimating];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"NewStatusViewController:viewWillAppear");
    [super viewWillAppear:animated];
    if (self.hasReloadedData)
    {
        [self.events loadResult:self.allResults];
        [self.events loadMedication:self.allMeds];
        [self.events loadMissedMedication:self.allMissedMeds];
        [self.events sortEventsAscending:YES];
        [self.chartView setNeedsDisplay];
    }
}


/**
 viewDidUnload
 */
#if  defined(__IPHONE_5_1) || defined (__IPHONE_5_0)
- (void)viewDidUnload
{
    self.chartView = nil;
    self.events = nil;
    self.latestCD4Count = nil;
    self.latestCD4Percent = nil;
    self.latestVL = nil;
    self.previousVL = nil;
    self.previousCD4Count = nil;
    self.latestCD4Percent = nil;
    [super viewDidUnload];
}
#endif
/**
 viewWillAppear called each time this view controller is shown. At this stage we make sure we reload the arrays
 that are needed to display the cell content and charts
 @animated
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
 */

/**
 loads the info viewer with short explanations on CD4 counts and Viral Loads
 @id sender
 */
- (void) showInfoView:(id)sender
{
	InfoDetailTableViewController *infoViewController = [[InfoDetailTableViewController alloc] initWithNibName:@"InfoDetailTableViewController" bundle:nil];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:infoViewController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
    [self presentModalViewController:navigationController animated:YES];
}


/**
 loads the settings view
 @id sender
 */
- (void) showSettingsView:(id)sender
{
    SettingsDetailViewController *settingsViewController = [[SettingsDetailViewController alloc] initWithNibName:@"SettingsDetailViewController" bundle:nil];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
    [self.navigationController presentModalViewController:navigationController animated:YES];
}


#pragma mark - Results getter

- (void)getStats
{
    self.latestCD4Count     = [self latestValueForType:@"CD4Count"];
    self.previousCD4Count   = [self previousValueForType:@"CD4Count"];
    self.latestCD4Percent   = [self latestValueForType:@"CD4Percent"];
    self.previousCD4Percent = [self previousValueForType:@"CD4Percent"];
    self.latestVL           = [self latestValueForType:@"ViralLoad"];
    self.previousVL         = [self previousValueForType:@"ViralLoad"];
}


- (NSNumber *)latestValueForType:(NSString *)type
{
    if (nil == self.allResults)
    {
        return nil;
    }
    if (0 == self.allResults.count)
    {
        return nil;
    }
    NSNumber *latestResult = nil;
    for (Results *result in self.allResults)
    {
        NSNumber *cd4 = result.CD4;
        NSNumber *cd4Percent = result.CD4Percent;
        NSNumber *vl = result.ViralLoad;
        if ([type isEqualToString:@"CD4Count"])
        {
            if (0 < [cd4 floatValue])
            {
                latestResult = cd4;
                break;
            }
        }
        else if ([type isEqualToString:@"CD4Percent"])
        {
            if (0 < [cd4Percent floatValue])
            {
                latestResult = cd4Percent;
                break;
            }
            
        }
        else if ([type isEqualToString:@"ViralLoad"])
        {
            if (0 <= [vl floatValue])
            {
                latestResult = vl;
                break;
            }
        }
    }
    return latestResult;    
}

- (NSNumber *)previousValueForType:(NSString *)type
{
    if (nil == self.allResults)
    {
        return nil;
    }
    if (self.allResults.count < 2)
    {
        return nil;
    }
    NSNumber *previousResult = nil;
    BOOL isFirstFound = NO;
    for (Results *result in self.allResults)
    {
        NSNumber *cd4 = result.CD4;
        NSNumber *cd4Percent = result.CD4Percent;
        NSNumber *vl = result.ViralLoad;
        if ([type isEqualToString:@"CD4Count"])
        {
            if (0 < [cd4 floatValue])
            {
                if (!isFirstFound)
                {
                    isFirstFound = YES;
                }
                else
                {
                    previousResult = cd4;
                    break;
                }
            }
        }
        else if ([type isEqualToString:@"CD4Percent"])
        {
            if (0 < [cd4Percent floatValue])
            {
                if (!isFirstFound)
                {
                    isFirstFound = YES;
                }
                else
                {
                    previousResult = cd4Percent;
                    break;                    
                }
            }
            
        }
        else if ([type isEqualToString:@"ViralLoad"])
        {
            if (0 <= [vl floatValue])
            {
                if (!isFirstFound)
                {
                    isFirstFound = YES;
                }
                else
                {
                    previousResult = vl;
                    break;                    
                }
            }
        }
    }

    return previousResult;
}



#pragma mark - Table view data source

/**
 2 sections. section 0 contains 2 status cells (CD4/Viral Load), section 1 contains 1 cell with the charts
 @tableView 
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

/**
 2 row in section 0, 1 row in section 1
 @tableView
 @section
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	if (0 == section)
    {
		return 3;
	}
    return 1;
}

/**
 for the results cells we use a height of 50 - for the chart we use a height of 230
 @tableView
 @indexPath
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (0 == indexPath.section)
    {
		return [self.sizeOfSummaryCell floatValue];
	}
	else
    {
		return [self.sizeOfChartCell floatValue];
	}
}

/**
 configure the CD4 Count status cell
 */
- (void)configureCD4Cell
{
    if (nil == self.cd4Cell)
    {
        return;
    }
    self.cd4Cell.title.text = NSLocalizedString(@"CD4 Count", @"CD4 Count");
    self.cd4Cell.title.textColor = DARK_YELLOW;
    [self.cd4Cell clearIndicatorsFromLayer];
	if (nil == self.allResults )
    {
        self.cd4Cell.result.text = NSLocalizedString(@"No results", nil);
        self.cd4Cell.result.textColor = [UIColor lightGrayColor];
        self.cd4Cell.change.text = @"";
		return;
	}
        
	if (0 == self.allResults.count || nil == self.latestCD4Count)
    {
        self.cd4Cell.result.text = NSLocalizedString(@"No results", nil);
        self.cd4Cell.result.textColor = [UIColor lightGrayColor];
        self.cd4Cell.change.text = @"";
        return;
	}
	
	int cd4Count = [self.latestCD4Count intValue];
	if (0 < cd4Count)
    {
        self.cd4Cell.result.text = [NSString stringWithFormat:@"%d",cd4Count];
	}
    
    if (nil != self.previousCD4Count)
    {
        int previousCD4 = [self.previousCD4Count intValue];
		if (0 < previousCD4 && 0 < cd4Count)
        {
			int diff = cd4Count - previousCD4;
            self.cd4Cell.change.text = [NSString stringWithFormat:@"%d", diff];
			
			if (0 > diff)
            {
                self.cd4Cell.change.textColor = DARK_RED;
                [self.cd4Cell indicator:self hasShape:downward isGood:NO];
			}
			else if (0 < diff)
            {
                self.cd4Cell.change.textColor = DARK_GREEN;
                [self.cd4Cell indicator:self hasShape:upward isGood:YES];
			}
            else
            {
                self.cd4Cell.change.text = @"";
                self.cd4Cell.change.textColor = [UIColor lightGrayColor];
                [self.cd4Cell indicator:self hasShape:neutral isGood:YES];
            }
		}
    }
    else
    {
        self.cd4Cell.change.text = @"";
    }
		
}
/**
 configure the CD4 Percent status cell
 */

- (void)configureCD4PercentCell
{
    if (nil == self.cd4PercentCell)
    {
        return;
    }
    self.cd4PercentCell.title.text = NSLocalizedString(@"CD4 %", @"CD4 %");
    self.cd4PercentCell.title.textColor = DARK_YELLOW;
    [self.cd4PercentCell clearIndicatorsFromLayer];
	if (nil == self.allResults)
    {
        self.cd4PercentCell.result.text = NSLocalizedString(@"No results", nil);
        self.cd4PercentCell.result.textColor = [UIColor lightGrayColor];
        self.cd4PercentCell.change.text = @"";
		return;
	}
    
	if (0 == self.allResults.count || nil == self.latestCD4Percent)
    {
        self.cd4PercentCell.result.text = NSLocalizedString(@"No results", nil);
        self.cd4PercentCell.result.textColor = [UIColor lightGrayColor];
        self.cd4PercentCell.change.text = @"";
        return;
	}
	
	float cd4Percent = [self.latestCD4Percent floatValue];
	if (0.0 < cd4Percent)
    {
        self.cd4PercentCell.result.text = [NSString stringWithFormat:@"%2.1f%%",cd4Percent];
	}
	
	if (nil != self.previousCD4Percent)
    {
        //		previous = (Results *)[self.allResults objectAtIndex:(count - 2)];
		float previousCD4Percent = [self.previousCD4Percent floatValue];
		if (0.0 < previousCD4Percent && 0 < cd4Percent)
        {
			float diff = cd4Percent - previousCD4Percent;
            self.cd4PercentCell.change.text = [NSString stringWithFormat:@"%2.1f%%", diff];
			
			if (0 > diff)
            {
                self.cd4PercentCell.change.textColor = DARK_RED;
                [self.cd4PercentCell indicator:self hasShape:downward isGood:NO];
			}
			else if (0 < diff)
            {
                self.cd4PercentCell.change.textColor = DARK_GREEN;
                [self.cd4PercentCell indicator:self hasShape:upward isGood:YES];
			}
            else
            {
                self.cd4PercentCell.change.text = @"";
                self.cd4PercentCell.change.textColor = [UIColor lightGrayColor];
                [self.cd4PercentCell indicator:self hasShape:neutral isGood:YES];
            }
            
		}
	}
	else
    {
        self.cd4PercentCell.change.text = @"";
	}
    
    
}

/**
 configure the viral load status cell
 */
- (void)configureViralLoadCell
{
    if (nil == self.vlCell)
    {
        return;
    }
    self.vlCell.title.text = NSLocalizedString(@"Viral Load", @"Viral Load");
    self.vlCell.title.textColor = DARK_BLUE;
    [self.vlCell clearIndicatorsFromLayer];
    
	if (nil == self.allResults)
    {
        self.vlCell.result.text = NSLocalizedString(@"No results", nil);
        self.vlCell.result.textColor = [UIColor lightGrayColor];
        self.vlCell.change.text = @"";
		return;
	}
    
	if (0 == self.allResults.count || nil == self.latestCD4Percent)
    {
        self.vlCell.result.text = NSLocalizedString(@"No results", nil);
        self.vlCell.result.textColor = [UIColor lightGrayColor];
        self.vlCell.change.text = @"";
        return;
	}

	int vlCount = [self.latestVL intValue];
    
	if (0 == vlCount)
    {
        self.vlCell.result.text = NSLocalizedString(@"undetectable", @"undetectable");
	}
	else if(0 < vlCount)
    {
        self.vlCell.result.text = [NSString stringWithFormat:@"%d",vlCount];
	}
    else
    {
        self.vlCell.result.text = @"";
    }
    	
	if (nil != self.previousVL)
    {
        //		previous = (Results *)[self.allResults objectAtIndex:(count - 2)];
		int previousVL = [self.previousVL intValue];
		if (0 < vlCount || 0 < previousVL)
        {
            int diff = vlCount - previousVL;
            self.vlCell.change.text = [NSString stringWithFormat:@"%d", diff];
            
			if (0 > diff)
            {
                self.vlCell.change.textColor = DARK_GREEN;
                [self.vlCell indicator:self hasShape:downward isGood:YES];
			}
			if (0 < diff)
            {
                self.vlCell.change.textColor = DARK_RED;
                [self.vlCell indicator:self hasShape:upward isGood:NO];
			}
            if (0 == diff)
            {
                self.vlCell.change.text = @"0";
                self.vlCell.change.textColor = [UIColor lightGrayColor];
                [self.vlCell indicator:self hasShape:neutral isGood:NO];
            }
		}
        if (0 == vlCount && 0 == previousVL)
        {
            self.vlCell.change.text = @"0";
            self.vlCell.change.textColor = [UIColor lightGrayColor];
        }
	}
	else
    {
        self.vlCell.change.text = @"";
	}
}

/**
 sets up the cells for this view
 @tableView
 @indexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (0 == indexPath.section)
    {
        NSString *identifier = [NSString stringWithFormat:@"SummaryCell%d",indexPath.row];
        SummaryCell *cell = (SummaryCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil)
        {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"SummaryCell"
                                                                owner:self
                                                              options:nil];
            for (id currentObject in cellObjects)
            {
                if ([currentObject isKindOfClass:[SummaryCell class]])
                {
                    cell = (SummaryCell *)currentObject;
                    break;
                }
            }
        }
        int row = indexPath.row;
        switch (row)
        {
            case 0:
                self.cd4Cell = cell;
                [self configureCD4Cell];
                break;
            case 1:
                self.cd4PercentCell = cell;
                [self configureCD4PercentCell];
                break;
            case 2:
                self.vlCell = cell;
                [self configureViralLoadCell];
                break;
        }
        return cell;        
	}
	if (1 == indexPath.section)
    {
        NSString *identifier = @"ChartViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
		if (nil == cell)
        {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:identifier];
		}
		cell.backgroundColor = BRIGHT_BACKGROUND;			
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        CGRect frame = CGRectMake(CGRectGetMinX(cell.bounds)+MARGINLEFT/2, CGRectGetMinY(cell.bounds), CGRectGetWidth(cell.bounds) - MARGINLEFT*1.5, [self.sizeOfChartCell floatValue]-5.0);
        HealthChartsViewPortrait *chart = [[HealthChartsViewPortrait alloc] initWithFrame:frame];
        [chart setEvents:self.events];
//        chart.events = self.events;
        
		[cell.contentView addSubview:chart];
		self.chartView = chart;
        return cell;
	}
    return nil;
}


#pragma mark - Table view delegate
/**
 sets the timing of the deselect
 @id
 */
- (void) deselect: (id) sender
{
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
        switch (indexPath.row)
        {
            case 0:
                [self.chartView showCD4];
                break;
            case 1:
                [self.chartView showCD4Percent];
                break;
            case 2:
                [self.chartView showViralLoad];
                break;
        }
    }
}

@end
