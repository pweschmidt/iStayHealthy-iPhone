//
//  NewResultsViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 29/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NewResultsViewController.h"
#import "iStayHealthyAppDelegate.h"
#import "iStayHealthyRecord.h"
#import "ResultDetailViewController.h"
#import "NSArray-Set.h"
#import "Results.h"
#import "GeneralSettings.h"
#import "ChartSettings.h"
#import "ResultChangeViewController.h"
#import "ResultListCell.h"
#import "UINavigationBar-Button.h"
#import "ResultsSettingsTableViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation NewResultsViewController

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

/**
 dealloc
 */


#pragma mark - View lifecycle

- (void)viewDidLoad
{
#ifdef APPDEBUG
    NSLog(@"NewResultsViewController viewDidLoad");
#endif
    [super viewDidLoad];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(loadResultDetailViewController)];
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(loadSetUpViewController)];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (navBar) {
        [navBar addButtonWithImageName:@"resultsnavbar.png" withTarget:self withSelector:@selector(gotoPOZ)];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

/**
 before view appears the data tables are being updated
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

/**
 loads the ResultDetailViewController
 */
- (void)loadResultDetailViewController{
	ResultDetailViewController *newRecordView = [[ResultDetailViewController alloc] initWithRecord:masterRecord];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newRecordView];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
	newRecordView.record = masterRecord;
}

/**
 loads the ResultsChangeViewController
 */
- (void)loadResultChangeViewController:(int)row{
    Results *results = (Results *)[self.allResultsInReverseOrder objectAtIndex:row];
	ResultChangeViewController *changeRecordView = [[ResultChangeViewController alloc] initWithResults:results withMasterRecord:masterRecord];
    
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:changeRecordView];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
}

- (void)loadSetUpViewController{
    ResultsSettingsTableViewController *settingsController = [[ResultsSettingsTableViewController alloc]initWithRecord:masterRecord];
    [self.navigationController pushViewController:settingsController animated:YES];
}



#pragma mark - Table view data source

/**
 only 1 section
 @tableView
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/**
 returns number of rows == number of saved results
 @tableView
 @section
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.allResultsInReverseOrder count];
}

/**
 returns cell height == 60.0
 @tableView
 @indexPath
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 60.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (0 == [self.allResultsInReverseOrder count]) {
        return NSLocalizedString(@"No Results Entered",nil);
    }
    else
        return @"";
}

/**
 loads/sets up the cells
 @tableView
 @indexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ResultListCell";
    ResultListCell *cell = (ResultListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"ResultListCell" owner:self options:nil];
        for (id currentObject in cellObjects) {
            if ([currentObject isKindOfClass:[ResultListCell class]]) {
                cell = (ResultListCell *)currentObject;
                break;
            }
        }
        
    }
	Results *current = (Results *)[self.allResultsInReverseOrder objectAtIndex:indexPath.row];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"dd MMM YYYY";
    cell.bloodView.layer.cornerRadius = 5;
    cell.serumsView.layer.cornerRadius = 5;
    cell.cd4ColourView.layer.cornerRadius = 5;
    cell.otherView.layer.cornerRadius = 5;
    
    if ( 0 < [current.CD4 floatValue] || 0 < [current.CD4Percent floatValue]) {
        cell.cd4ColourView.backgroundColor = DARK_YELLOW;
    }
    else {
        cell.cd4ColourView.backgroundColor = [UIColor clearColor];
    }
    
    if (0 <= [current.ViralLoad floatValue] || 0 <= [current.HepCViralLoad floatValue]) {
        cell.serumsView.backgroundColor = DARK_BLUE;
    }
    else {
        cell.serumsView.backgroundColor = [UIColor clearColor];
    }
    if (0 < [current.Glucose floatValue] || 0 < [current.HDL floatValue] || [current.LDL floatValue] || 0 < [current.TotalCholesterol floatValue]) {
        cell.bloodView.backgroundColor = DARK_RED;
    }
    else {
        cell.bloodView.backgroundColor = [UIColor clearColor];
    }
    
    if (0 < [current.Weight floatValue] || (0 < [current.Systole floatValue] && 0 < [current.Diastole floatValue])) {
        cell.otherView.backgroundColor = DARK_GREEN;
    }
    else {
        cell.otherView.backgroundColor = [UIColor clearColor];
    }
    
    [[cell dateLabel]setText:[formatter stringFromDate:current.ResultsDate]];
    [[cell cd4Title]setText:NSLocalizedString(@"CD4 Count",nil)];
    [[cell cd4Title]setTextColor:TEXTCOLOUR];
    [cell setCD4:current.CD4];
    [[cell cd4PercentTitle]setText:NSLocalizedString(@"CD4 %", @"CD4 %")];
    [[cell cd4PercentTitle]setTextColor:TEXTCOLOUR];
    [cell setCD4Percent:current.CD4Percent];
    [[cell vlTitle]setText:NSLocalizedString(@"Viral Load", @"Viral Load")];
    [[cell vlTitle]setTextColor:TEXTCOLOUR];
    [cell setViralLoad:current.ViralLoad];
    return (UITableViewCell *)cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    [self loadResultChangeViewController:indexPath.row];
}



@end
