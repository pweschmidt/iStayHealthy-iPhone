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
#import "ResultListCell.h"
#import "UINavigationBar-Button.h"
#import <QuartzCore/QuartzCore.h>
#import "Utilities.h"
#import "WebViewController.h"

@interface NewResultsViewController ()
@property (nonatomic, strong) NSArray *allResultsInReverseOrder;
@property (nonatomic, strong) SQLDataTableController *dataController;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, assign) BOOL hasReloadedData;
- (void)setUpData;
@end

@implementation NewResultsViewController


- (void)setUpData
{
	iStayHealthyAppDelegate *appDelegate = (iStayHealthyAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.context = appDelegate.managedObjectContext;
    self.dataController = [[SQLDataTableController alloc] initForEntityName:@"Results" sortBy:@"ResultsDate" isAscending:NO context:self.context];
    
    self.allResultsInReverseOrder = [self.dataController entriesForEntity];    
}

- (void)reloadData:(NSNotification *)note
{
    NSLog(@"reloadData");
    self.hasReloadedData = YES;
    [self.activityIndicator stopAnimating];
    if (nil != note)
    {
        self.allResultsInReverseOrder = [self.dataController entriesForEntity];
        [self.tableView reloadData];
    }
}

- (void)start
{
    if (![self.activityIndicator isAnimating] && !self.hasReloadedData)
    {
        [self.activityIndicator startAnimating];
    }    
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hasReloadedData = NO;
    [self setUpData];
      
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (navBar)
    {
        [navBar addButtonWithTitle:@"Results" target:self selector:@selector(gotoPOZ)];
    }
    
    CGRect frame = [Utilities frameFromSize:self.view.bounds.size];
    self.activityIndicator = [Utilities activityIndicatorViewWithFrame:frame];
    [self.view insertSubview:self.activityIndicator aboveSubview:self.tableView];
    
    
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
- (void)loadResultDetailViewController
{
    ResultDetailViewController *newRecordView = [[ResultDetailViewController alloc] initWithContext:self.context];
//	ResultDetailViewController *newRecordView = [[ResultDetailViewController alloc] initWithRecord:self.masterRecord];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newRecordView];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
}

/**
 loads the ResultsChangeViewController
 */
- (void)loadResultChangeViewController:(int)row
{
    Results *results = (Results *)[self.allResultsInReverseOrder objectAtIndex:row];
    ResultDetailViewController *changeRecordView = [[ResultDetailViewController alloc] initWithResults:results context:self.context];
//	ResultDetailViewController *changeRecordView = [[ResultDetailViewController alloc] initWithResults:results withMasterRecord:self.masterRecord];
    
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:changeRecordView];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
}




#pragma mark - Table view data source

/**
 only 1 section
 @tableView
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/**
 returns number of rows == number of saved results
 @tableView
 @section
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.allResultsInReverseOrder count];
}

/**
 returns cell height == 60.0
 @tableView
 @indexPath
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (0 == [self.allResultsInReverseOrder count])
    {
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
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"ResultListCell";
    ResultListCell *cell = (ResultListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"ResultListCell" owner:self options:nil];
        for (id currentObject in cellObjects)
        {
            if ([currentObject isKindOfClass:[ResultListCell class]])
            {
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
    
    if ( 0 < [current.CD4 floatValue] || 0 < [current.CD4Percent floatValue])
    {
        cell.cd4ColourView.backgroundColor = DARK_YELLOW;
    }
    else
    {
        cell.cd4ColourView.backgroundColor = [UIColor clearColor];
    }
    
    if (0 <= [current.ViralLoad floatValue] || 0 <= [current.HepCViralLoad floatValue])
    {
        cell.serumsView.backgroundColor = DARK_BLUE;
    }
    else
    {
        cell.serumsView.backgroundColor = [UIColor clearColor];
    }
    if ([current.Glucose floatValue] > 0.0 || [current.HDL floatValue] > 0.0 || [current.LDL floatValue] > 0.0 ||  [current.TotalCholesterol floatValue] > 0.0 || [current.WhiteBloodCellCount floatValue] > 0.0 ||
        [current.redBloodCellCount floatValue] > 0.0 || [current.Hemoglobulin floatValue] > 0.0 ||
        [current.PlateletCount floatValue] > 0.0)
    {
        cell.bloodView.backgroundColor = DARK_RED;
    }
    else
    {
        cell.bloodView.backgroundColor = [UIColor clearColor];
    }
    
    if (0 < [current.Weight floatValue] || (0 < [current.Systole floatValue] && 0 < [current.Diastole floatValue]))
    {
        cell.otherView.backgroundColor = DARK_GREEN;
    }
    else
    {
        cell.otherView.backgroundColor = [UIColor clearColor];
    }
    
    cell.dateLabel.text = [formatter stringFromDate:current.ResultsDate];
    cell.cd4Title.text = NSLocalizedString(@"CD4 Count",nil);
    cell.cd4Title.textColor = TEXTCOLOUR;
    [cell setCD4:current.CD4];
    cell.cd4PercentTitle.text = NSLocalizedString(@"CD4 %", @"CD4 %");
    cell.cd4PercentTitle.textColor = TEXTCOLOUR;
    [cell setCD4Percent:current.CD4Percent];
    cell.vlTitle.text = NSLocalizedString(@"Viral Load", @"Viral Load");
    cell.vlTitle.textColor = TEXTCOLOUR;
    [cell setViralLoad:current.ViralLoad];
    return (UITableViewCell *)cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    [self loadResultChangeViewController:indexPath.row];
}



@end
