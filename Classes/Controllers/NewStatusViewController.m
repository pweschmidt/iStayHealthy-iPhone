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
}

#pragma mark - View lifecycle
/**
 viewDidLoad
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
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
    if (0 < [self.events.allChartEvents count])
    {
        [self.events.allChartEvents removeAllObjects];
    }
    self.hasReloadedData = YES;
    NSArray *results = [self.resultsController entriesForEntity];
    self.allResults = [self.resultsController cleanEntriesForData:results table:kResultsTable];
    NSArray *meds = [self.medsController entriesForEntity];
    self.allMeds = [self.medsController cleanEntriesForData:meds table:kMedicationTable];
    NSArray *missed  = [self.missedController entriesForEntity];
    self.allMissedMeds = [self.missedController cleanEntriesForData:missed table:kMissedMedicationTable];
    
    [self.activityIndicator stopAnimating];

    [self.events loadResult:self.allResults];
    [self.events loadMedication:self.allMeds];
    [self.events loadMissedMedication:self.allMissedMeds];
    [self.events sortEventsAscending:YES];
    [self getStats];
    [self.chartView setNeedsDisplay];
    [self.tableView reloadData];
}

- (void)start
{
    if (![self.activityIndicator isAnimating] && !self.hasReloadedData)
    {
        [self.activityIndicator startAnimating];
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
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (0 < [self.events.allChartEvents count])
    {
        [self.events.allChartEvents removeAllObjects];
    }
    
    [self.events loadResult:self.allResults];
    [self.events loadMedication:self.allMeds];
    [self.events loadMissedMedication:self.allMissedMeds];
    [self.events sortEventsAscending:YES];
    [self getStats];
    [self.chartView setNeedsDisplay];
    [self.tableView reloadData];
}


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
- (void)configureCD4Cell:(SummaryCell *)cell
{
    cell.title.text = NSLocalizedString(@"CD4 Count", @"CD4 Count");
    cell.title.textColor = DARK_YELLOW;
    [cell clearIndicatorsFromLayer];
	if (nil == self.allResults )
    {
        cell.result.text = NSLocalizedString(@"No results", nil);
        cell.result.textColor = [UIColor lightGrayColor];
        cell.change.text = @"";
		return;
	}
        
	if (0 == self.allResults.count || nil == self.latestCD4Count)
    {
        cell.result.text = NSLocalizedString(@"No results", nil);
        cell.result.textColor = [UIColor lightGrayColor];
        cell.change.text = @"";
        return;
	}
	
	int cd4Count = [self.latestCD4Count intValue];
	if (0 < cd4Count)
    {
        cell.result.text = [NSString stringWithFormat:@"%d",cd4Count];
	}
    
    if (nil != self.previousCD4Count)
    {
        int previousCD4 = [self.previousCD4Count intValue];
		if (0 < previousCD4 && 0 < cd4Count)
        {
			int diff = cd4Count - previousCD4;
            cell.change.text = [NSString stringWithFormat:@"%d", diff];
			
			if (0 > diff)
            {
                cell.change.textColor = DARK_RED;
                [cell indicator:self hasShape:downward isGood:NO];
			}
			else if (0 < diff)
            {
                cell.change.textColor = DARK_GREEN;
                [cell indicator:self hasShape:upward isGood:YES];
			}
            else
            {
                cell.change.text = @"";
                cell.change.textColor = [UIColor lightGrayColor];
                [cell indicator:self hasShape:neutral isGood:YES];
            }
		}
    }
    else
    {
        cell.change.text = @"";
    }
		
}
/**
 configure the CD4 Percent status cell
 */

- (void)configureCD4PercentCell:(SummaryCell *)cell
{
    cell.title.text = NSLocalizedString(@"CD4 %", @"CD4 %");
    cell.title.textColor = DARK_YELLOW;
    [cell clearIndicatorsFromLayer];
	if (nil == self.allResults)
    {
        cell.result.text = NSLocalizedString(@"No results", nil);
        cell.result.textColor = [UIColor lightGrayColor];
        cell.change.text = @"";
		return;
	}
    
	if (0 == self.allResults.count || nil == self.latestCD4Percent)
    {
        cell.result.text = NSLocalizedString(@"No results", nil);
        cell.result.textColor = [UIColor lightGrayColor];
        cell.change.text = @"";
        return;
	}
	
	float cd4Percent = [self.latestCD4Percent floatValue];
	if (0.0 < cd4Percent)
    {
        cell.result.text = [NSString stringWithFormat:@"%2.1f%%",cd4Percent];
	}
	
	if (nil != self.previousCD4Percent)
    {
        //		previous = (Results *)[self.allResults objectAtIndex:(count - 2)];
		float previousCD4Percent = [self.previousCD4Percent floatValue];
		if (0.0 < previousCD4Percent && 0 < cd4Percent)
        {
			float diff = cd4Percent - previousCD4Percent;
            cell.change.text = [NSString stringWithFormat:@"%2.1f%%", diff];
			
			if (0 > diff)
            {
                cell.change.textColor = DARK_RED;
                [cell indicator:self hasShape:downward isGood:NO];
			}
			else if (0 < diff)
            {
                cell.change.textColor = DARK_GREEN;
                [cell indicator:self hasShape:upward isGood:YES];
			}
            else
            {
                cell.change.text = @"";
                cell.change.textColor = [UIColor lightGrayColor];
                [cell indicator:self hasShape:neutral isGood:YES];
            }
            
		}
	}
	else
    {
        cell.change.text = @"";
	}
    
    
}

/**
 configure the viral load status cell
 */
- (void)configureViralLoadCell:(SummaryCell *)cell
{
    cell.title.text = NSLocalizedString(@"Viral Load", @"Viral Load");
    cell.title.textColor = DARK_BLUE;
    [cell clearIndicatorsFromLayer];
    
	if (nil == self.allResults)
    {
        cell.result.text = NSLocalizedString(@"No results", nil);
        cell.result.textColor = [UIColor lightGrayColor];
        cell.change.text = @"";
		return;
	}
    
	if (0 == self.allResults.count || nil == self.latestCD4Percent)
    {
        cell.result.text = NSLocalizedString(@"No results", nil);
        cell.result.textColor = [UIColor lightGrayColor];
        cell.change.text = @"";
        return;
	}

	int vlCount = [self.latestVL intValue];
    
	if (1 < vlCount)
    {
        cell.result.text = [NSString stringWithFormat:@"%d",vlCount];
	}
	else if(0 <= vlCount && 1 >= vlCount)
    {
        cell.result.text = NSLocalizedString(@"undetectable", @"undetectable");
	}
    else
    {
        cell.result.text = @"";
    }
    	
	if (nil != self.previousVL)
    {
        //		previous = (Results *)[self.allResults objectAtIndex:(count - 2)];
		int previousVL = [self.previousVL intValue];
		if (0 <= vlCount && 0 <= previousVL && ( 1 < vlCount || 1 < previousVL ))
        {
            int diff = vlCount - previousVL;
            cell.change.text = [NSString stringWithFormat:@"%d", diff];
            
			if (0 > diff)
            {
                cell.change.textColor = DARK_GREEN;
                [cell indicator:self hasShape:downward isGood:YES];
			}
			if (0 < diff)
            {
                cell.change.textColor = DARK_RED;
                [cell indicator:self hasShape:upward isGood:NO];
			}
            if (0 == diff)
            {
                cell.change.text = @"0";
                cell.change.textColor = [UIColor lightGrayColor];
                [cell indicator:self hasShape:neutral isGood:NO];
            }
		}
        if ((0 <= vlCount && 1 >= vlCount) && (0 <= previousVL && 1 >= previousVL))
        {
            cell.change.text = @"0";
            cell.change.textColor = [UIColor lightGrayColor];
        }
	}
	else
    {
        cell.change.text = @"";
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
        NSString *identifier = @"SummaryCell";
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
                [self configureCD4Cell:cell];
                break;
            case 1:
                [self configureCD4PercentCell:cell];
                break;
            case 2:
                [self configureViralLoadCell:cell];
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
