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

@implementation NewStatusViewController
@synthesize chartView;
@synthesize events;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

/**
 dealloc
 */
- (void)dealloc {
	[chartView release];
    [events release];
    [super dealloc];
}


#pragma mark - View lifecycle
/**
 viewDidLoad
 */
- (void)viewDidLoad
{
    [super viewDidLoad];

	UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[infoButton addTarget:self action:@selector(showInfoView:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *actionButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showSettingsView:)]autorelease];
    
    
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:infoButton]autorelease];
    self.navigationItem.leftBarButtonItem = actionButton;
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (navBar) {
        [navBar addButtonWithImageName:@"chartsnavbar.png" withTarget:self withSelector:@selector(gotoPOZ)];
    }
    ChartEvents *tmpEvents = [[ChartEvents alloc]init];
	self.events = tmpEvents;
    [tmpEvents release];
}

- (void)reloadData:(NSNotification *)note{
    [super reloadData:note];
    if (0 < [self.events.allChartEvents count]) {
        [self.events.allChartEvents removeAllObjects];
    }
    
    [self.events loadResult:self.allResults];
    [self.events loadMedication:self.allMeds];
    [self.events loadMissedMedication:self.allMissedMeds];
    [self.events sortEventsAscending:YES];
    [self.chartView setNeedsDisplay];
}

/**
 viewDidUnload
 */
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

/**
 viewWillAppear called each time this view controller is shown. At this stage we make sure we reload the arrays
 that are needed to display the cell content and charts
 @animated
 */
- (void)viewWillAppear:(BOOL)animated
{
#ifdef APPDEBUG	
	NSLog(@"**** NewStatusViewController::viewWillAppear ENTERING");
#endif
    [super viewWillAppear:animated];
    if (0 < [self.events.allChartEvents count]) {
        [self.events.allChartEvents removeAllObjects];
    }
    
    [self.events loadResult:self.allResults];
    [self.events loadMedication:self.allMeds];
    [self.events loadMissedMedication:self.allMissedMeds];
    [self.events sortEventsAscending:YES];
#ifdef APPDEBUG	
	NSLog(@"**** NewStatusViewController::viewWillAppear LEAVING");
#endif
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
    [settingsViewController release];
}


#pragma mark - Results getter
/**
 the latest result
 */
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

/**
 the previous result (or nil if none exists)
 */

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


#pragma mark - Table view data source

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
 configure the CD4 Count status cell
 */
- (void)configureCD4Cell:(SummaryCell *)cell{
    [[cell title]setText:NSLocalizedString(@"CD4 Count", nil)];
    [[cell title]setTextColor:DARK_YELLOW];
    
	if (!self.allResults) {
		return;
	}
	NSUInteger count = [self.allResults count];
        
	if (0 == count) {
        [[cell result]setText:NSLocalizedString(@"No results", nil)];
        [[cell result]setTextColor:[UIColor lightGrayColor]];
        [[cell change]setText:@""];
        [[cell imageView]setImage:nil];
		return;
	}
    Results *current = [self latestResult:@"CD4Count"];
    if (!current) {
        [[cell result]setText:NSLocalizedString(@"No results", nil)];
        [[cell result]setTextColor:[UIColor lightGrayColor]];
        [[cell change]setText:@""];
        [[cell imageView]setImage:nil];
		return;
    }
	
	int cd4Count = [current.CD4 intValue];
	if (0 < cd4Count) {
        [[cell result]setText:[NSString stringWithFormat:@"%d",cd4Count]];
	}
	
	Results *previous = [self previousResult:@"CD4Count"];
	if (previous) {
		int previousCD4 = [previous.CD4 intValue];
		if (0 < previousCD4 && 0 < cd4Count) {
			int diff = cd4Count - previousCD4;
            [[cell change]setText:[NSString stringWithFormat:@"%d", diff]];
			
			if (0 > diff) {
                [[cell change]setTextColor:DARK_RED];
                [[cell imageView]setImage:[UIImage imageNamed:@"downredweb.png"]];
			}
			else if (0 < diff){
                [[cell change]setTextColor:DARK_GREEN];
                [[cell imageView]setImage:[UIImage imageNamed:@"upgreenweb.png"]];
			}
            else{
                [[cell change]setText:@""];
                [[cell change]setTextColor:[UIColor lightGrayColor]];            
                [[cell imageView] setImage:[UIImage imageNamed:@"neutralflat.png"]];
            }
		}
	}
	else {
        [[cell change]setText:@""];
        [[cell imageView]setImage:nil];
	}    
	
}
/**
 configure the CD4 Percent status cell
 */

- (void)configureCD4PercentCell:(SummaryCell *)cell{
    [[cell title]setText:NSLocalizedString(@"CD4 %", nil)];
    [[cell title]setTextColor:DARK_YELLOW];
    
	if (!self.allResults) {
		return;
	}
	NSUInteger count = [self.allResults count];
    
    
	if (0 == count) {
        [[cell result]setText:NSLocalizedString(@"No results", nil)];
        [[cell result]setTextColor:[UIColor lightGrayColor]];
        [[cell change]setText:@""];
        [[cell imageView]setImage:nil];
		return;
	}
    Results *current = [self latestResult:@"CD4Percent"];
    if (!current) {
        [[cell result]setText:NSLocalizedString(@"No results", nil)];
        [[cell result]setTextColor:[UIColor lightGrayColor]];
        [[cell change]setText:@""];
        [[cell imageView]setImage:nil];
		return;
    }
	
	float cd4Percent = [current.CD4Percent floatValue];
	if (0.0 < cd4Percent) {
        [[cell result]setText:[NSString stringWithFormat:@"%2.1f%%",cd4Percent]];
	}
	
	Results *previous = [self previousResult:@"CD4Percent"];
	if (previous) {
        //		previous = (Results *)[self.allResults objectAtIndex:(count - 2)];
		float previousCD4Percent = [previous.CD4Percent floatValue];
		if (0.0 < previousCD4Percent && 0 < cd4Percent) {
			float diff = cd4Percent - previousCD4Percent;
            [[cell change]setText:[NSString stringWithFormat:@"%2.1f%%", diff]];
			
			if (0 > diff) {
                [[cell change]setTextColor:DARK_RED];
                [[cell imageView]setImage:[UIImage imageNamed:@"downredweb.png"]];
			}
			else if (0 < diff){
                [[cell change]setTextColor:DARK_GREEN];
                [[cell imageView]setImage:[UIImage imageNamed:@"upgreenweb.png"]];
			}
            else{
                [[cell change]setText:@""];
                [[cell change]setTextColor:[UIColor lightGrayColor]];                        
                [[cell imageView] setImage:[UIImage imageNamed:@"neutralflat.png"]];
            }
            
		}
	}
	else {
        [[cell change]setText:@""];
        [[cell imageView]setImage:nil];
	}
    
    
}

/**
 configure the viral load status cell
 */
- (void)configureViralLoadCell:(SummaryCell *)cell{
    [[cell title]setText:NSLocalizedString(@"Viral Load", nil)];
    [[cell title]setTextColor:DARK_BLUE];
	if (!self.allResults) {
		return;
	}
	NSUInteger count = [self.allResults count];
	if (0 == count) {
        [[cell result]setText:NSLocalizedString(@"No results", nil)];
        [[cell result]setTextColor:[UIColor lightGrayColor]];
        [[cell change]setText:@""];
        [[cell imageView]setImage:nil];
		return;
	}
    Results *current = [self latestResult:@"ViralLoad"];
    if (!current) {
        [[cell result]setText:NSLocalizedString(@"No results", nil)];
        [[cell result]setTextColor:[UIColor lightGrayColor]];
        [[cell change]setText:@""];
        [[cell imageView]setImage:nil];
		return;
    }
	int vlCount = [current.ViralLoad intValue];
    
	if (10 < vlCount) {
        [[cell result]setText:[NSString stringWithFormat:@"%d",vlCount]];
	}
	if(0 <= vlCount && 10 >= vlCount){
        [[cell result]setText:NSLocalizedString(@"undetectable", nil)];
	}
    if (0 > vlCount) {
        [[cell result]setText:NSLocalizedString(@"n/a", nil)];
    }
    
	
	Results *previous = [self previousResult:@"ViralLoad"];
	if (previous) {
        //		previous = (Results *)[self.allResults objectAtIndex:(count - 2)];
		int previousVL = [previous.ViralLoad intValue];
		if (10 < vlCount && 10 < previousVL) {
            int diff = vlCount - previousVL;
            [[cell change]setText:[NSString stringWithFormat:@"%d", diff]];
            
			if (0 > diff) {
                [[cell change]setTextColor:DARK_GREEN];
                [[cell imageView]setImage:[UIImage imageNamed:@"downgreenweb.png"]];
			}
			if (0 < diff){
                [[cell change]setTextColor:DARK_RED];
                [[cell imageView]setImage:[UIImage imageNamed:@"upredweb.png"]];
			}
            if (0 == diff) {
                [[cell change]setText:@""];
                [[cell change]setTextColor:[UIColor lightGrayColor]];
                [[cell imageView] setImage:[UIImage imageNamed:@"neutralflat.png"]];
            }
		}
        if ((0 <= vlCount && 10 >= vlCount) && (0 <= previousVL && 10 >= previousVL)) {
            [[cell change]setText:@"0"];
            [[cell change]setTextColor:[UIColor lightGrayColor]];
            [[cell imageView] setImage:[UIImage imageNamed:@"neutralflat.png"]];
        }
	}
	else {
        [[cell change]setText:@""];
        [[cell imageView]setImage:nil];
	}    
}

/**
 sets up the cells for this view
 @tableView
 @indexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	if (0 == indexPath.section) {
        NSString *identifier = @"SummaryCell";
        SummaryCell *cell = (SummaryCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"SummaryCell" owner:self options:nil];
            for (id currentObject in cellObjects) {
                if ([currentObject isKindOfClass:[SummaryCell class]]) {
                    cell = (SummaryCell *)currentObject;
                    break;
                }
            }
        }
        int row = indexPath.row;
        switch (row) {
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
	if (1 == indexPath.section) {
        NSString *identifier = @"ChartViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
		if (nil == cell) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
		}
		cell.backgroundColor = BRIGHT_BACKGROUND;			
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        CGRect frame = CGRectMake(CGRectGetMinX(cell.bounds)+MARGINLEFT/2, CGRectGetMinY(cell.bounds), CGRectGetWidth(cell.bounds) - MARGINLEFT*1.5, CHARTCELLHEIGHT-5.0);
        HealthChartsViewPortrait *chart = [[HealthChartsViewPortrait alloc] initWithFrame:frame];
        [chart setEvents:self.events];
//        chart.events = self.events;
        
		[cell.contentView addSubview:chart];
		self.chartView = chart;
		[chart release];
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
    if (0 == indexPath.section) {
        [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
        switch (indexPath.row) {
            case 0:
                [chartView showCD4];
                break;
            case 1:
                [chartView showCD4Percent];
                break;
            case 2:
                [chartView showViralLoad];
                break;
        }
    }
}

@end
