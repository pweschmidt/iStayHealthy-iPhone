//
//  HIVMedicationViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 29/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HIVMedicationViewController.h"
#import "iStayHealthyAppDelegate.h"
#import "MedicationDetailTableViewController.h"
#import "MedicationChangeTableViewController.h"
#import "NSArray-Set.h"
#import "Medication.h"
#import "MissedMedication.h"
#import "GeneralSettings.h"
#import "SideEffectsViewController.h"
#import "MissedMedViewController.h"
#import "PreviousMedViewController.h"
#import "HIVMedListCell.h"
#import "HIVMedSupportCell.h"
#import "UINavigationBar-Button.h"
#import "Utilities.h"


@interface HIVMedicationViewController ()
@property (nonatomic, strong) NSArray *allMeds;
@property (nonatomic, strong) NSArray *allMissedMeds;
@property (nonatomic, strong) NSArray *allSideEffects;
@property (nonatomic, strong) NSArray *allPreviousMedications;
@property (nonatomic, strong) SQLDataTableController *medController;
@property (nonatomic, strong) SQLDataTableController *missedController;
@property (nonatomic, strong) SQLDataTableController *previousController;
@property (nonatomic, strong) SQLDataTableController *effectsController;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, assign) BOOL hasReloadedData;
- (void)setUpData;
@property NSUInteger stateIndex;
- (void)loadPreviousMedsController;
@end

@implementation HIVMedicationViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setUpData
{
	iStayHealthyAppDelegate *appDelegate = (iStayHealthyAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.context = appDelegate.managedObjectContext;
    self.medController = [[SQLDataTableController alloc] initForEntityType:kMedicationTable
                                                                    sortBy:@"StartDate"
                                                               isAscending:NO
                                                                   context:self.context];
    
    self.allMeds = [self.medController cleanedEntries];

    self.missedController = [[SQLDataTableController alloc] initForEntityType:kMissedMedicationTable
                                                                    sortBy:@"MissedDate"
                                                               isAscending:NO
                                                                   context:self.context];
    
    self.allMissedMeds = [self.missedController cleanedEntries];

    self.previousController = [[SQLDataTableController alloc] initForEntityType:kPreviousMedicationTable
                                                                    sortBy:@"endDate"
                                                               isAscending:NO
                                                                   context:self.context];
    
    self.allPreviousMedications = [self.previousController cleanedEntries];

    self.effectsController = [[SQLDataTableController alloc] initForEntityType:kSideEffectsTable
                                                                    sortBy:@"SideEffectDate"
                                                               isAscending:YES
                                                                   context:self.context];
    
    self.allSideEffects = [self.effectsController cleanedEntries];


}

- (void)reloadData:(NSNotification *)note
{
    self.hasReloadedData = YES;
    if (nil != note)
    {
        self.allMeds = [self.medController cleanedEntries];
        self.allMissedMeds = [self.missedController cleanedEntries];
        self.allPreviousMedications = [self.previousController cleanedEntries];
        self.allSideEffects = [self.effectsController cleanedEntries];
        [self.tableView reloadData];
    }
    [self.activityIndicator stopAnimating];
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
#ifdef APPDEBUG
    NSLog(@"HIVMedicationViewController viewDidLoad");
#endif
    [super viewDidLoad];
    self.hasReloadedData = NO;
    [self setUpData];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(loadMedicationDetailViewController)];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (navBar)
    {
        [navBar addButtonWithTitle:@"HIV Drugs" target:self selector:@selector(gotoPOZ)];
    }
    CGRect frame = [Utilities frameFromSize:self.view.bounds.size];
    self.activityIndicator = [Utilities activityIndicatorViewWithFrame:frame];
    [self.view insertSubview:self.activityIndicator aboveSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)loadPreviousMedsController
{
    PreviousMedViewController *viewController = [[PreviousMedViewController alloc]initWithContext:self.context];
    [self.navigationController pushViewController:viewController animated:YES];    
}

/**
 loads the MedicationDetailViewController - to add new Combi therapy
 */
- (void)loadMedicationDetailViewController
{
	MedicationDetailTableViewController *newMedsView = [[MedicationDetailTableViewController alloc] initWithContext:self.context];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newMedsView];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
}

/**
 loads the MedicationChangeDetailViewController - to add new Combi therapy
 */
- (void)loadMedicationChangeDetailViewController:(NSIndexPath *)selectedIndexPath
{
    Medication *med = (Medication *)[self.allMeds objectAtIndex:selectedIndexPath.row];
	MedicationChangeTableViewController *changedMedsView = [[MedicationChangeTableViewController alloc]initWithMedication:med context:self.context];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:changedMedsView];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
}

- (void)loadSideEffectsController
{
    SideEffectsViewController *sideController = [[SideEffectsViewController alloc] initWithContext:self.context
                                                                                       medications:self.allMeds];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:sideController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
}

- (void)loadMissedMedicationsController
{
    MissedMedViewController *missedController = [[MissedMedViewController alloc] initWithContext:self.context medications:self.allMeds];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:missedController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
}



#pragma mark - Table view data source

/**
 2 sections: the first for the number of current HIV drugs. the second for the number of missed doses (if any)
 @tableView
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

/**
 returns number of rows == number of saved medications
 @tableView
 @section
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return self.allMeds.count;
    }
    else
    {
        if (self.allPreviousMedications.count == 0 && self.allMeds.count == 0)
        {
            return 0;
        }
        else
            return 3;
    }
}

/**
 cell height can be either 70 (for medication cells) or 48 for the cells listing missed medication dates
 @tableView
 @indexPath
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (0 == self.allMeds.count && 0 == self.allPreviousMedications.count)
    {
        if (0 == section)
        {
            return NSLocalizedString(@"No HIV Treatment Listed", @"No HIV Treatment Listed");
        }
    }
    else
    {
        if (0 == section)
        {
            if (0 == self.allMeds.count)
            {
                return NSLocalizedString(@"No Current HIV Treatment", @"No HIV Treatment Listed");
            }
            else
            {
                return NSLocalizedString(@"Current HIV Treatment",nil);
            }
        }
    }
    return @"";
}

/**
 gets the string from the medname. This could contain a / 
 */
- (NSString *)getStringFromName:(NSString *)name
{
    NSArray *stringArray = [name componentsSeparatedByString:@"/"];
    NSString *imageName = [(NSString *)[stringArray objectAtIndex:0]lowercaseString];
    NSArray *finalArray = [imageName componentsSeparatedByString:@" "];
    
    return [(NSString *)[finalArray objectAtIndex:0]lowercaseString];
}




/**
 sets up the cells in the table
 @tableView
 @indexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (0 == indexPath.section)
    {
        NSString *identifier = @"HIVMedListCell";
        HIVMedListCell *cell = (HIVMedListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"HIVMedListCell"
                                                            owner:self
                                                          options:nil];
        for (id currentObject in cellObjects)
        {
            if ([currentObject isKindOfClass:[HIVMedListCell class]])
            {
                cell = (HIVMedListCell *)currentObject;
                break;
            }
        }
        Medication *medication = (Medication *)[self.allMeds objectAtIndex:indexPath.row];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"dd MMM YYYY";
        [[cell date]setText:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Start Date", nil),[formatter stringFromDate:medication.StartDate]]];
        [[cell name]setText:medication.Name];
        [[cell content]setText:medication.Drug];
        NSString *shortenedName = [self getStringFromName:medication.Name];
        NSString *pillPath = [[NSBundle mainBundle]
                              pathForResource:[shortenedName lowercaseString] ofType:@"png"];
        cell.medImageView.image = [UIImage imageWithContentsOfFile:pillPath];
        return cell;
    }
    else
    {
        NSString *identifier = @"HIVMedSupportCell";
        HIVMedSupportCell *cell = (HIVMedSupportCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"HIVMedSupportCell"
                                                            owner:self
                                                          options:nil];
        for (id currentObject in cellObjects)
        {
            if ([currentObject isKindOfClass:[HIVMedSupportCell class]])
            {
                cell = (HIVMedSupportCell *)currentObject;
                break;
            }
        }
        
        int row = indexPath.row;
        switch (row)
        {
            case 0:
                cell.medImageView.image = [UIImage imageNamed:@"sideeffects.png"];
                [[cell support]setText:NSLocalizedString(@"Side Effects", @"Side Effects")];
                [[cell count]setText:[NSString stringWithFormat:@"%d",[self.allSideEffects count]]];
                if (0 < [self.allSideEffects count]) {
                    [[cell count]setTextColor:DARK_RED];
                }
                break;
            case 1:
                cell.medImageView.image = [UIImage imageNamed:@"missed.png"];
                [[cell support]setText:NSLocalizedString(@"Missed", @"Missed")];
                [[cell count]setText:[NSString stringWithFormat:@"%d",[self.allMissedMeds count]]];
                if (0 < [self.allMissedMeds count]) {
                    [[cell count]setTextColor:DARK_RED];
                }
                break;
            case 2:
                cell.medImageView.image = [UIImage imageNamed:@"stop.png"];
                cell.support.text = NSLocalizedString(@"Previous Medication", @"Previous");
                cell.count.text = [NSString stringWithFormat:@"%d",self.allPreviousMedications.count];
                if (0 < self.allPreviousMedications.count)
                {
                    cell.count.textColor = DARK_YELLOW;
                }
                break;
        }
        
        return cell;
    }

}
#pragma mark -
#pragma mark Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (0 == indexPath.section)
    {
        [self loadMedicationChangeDetailViewController:indexPath];
    }
    else if(1 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            [self loadSideEffectsController];
        }
        if(1 == indexPath.row)
        {
            [self loadMissedMedicationsController];
        }
        if (2 == indexPath.row)
        {
            [self loadPreviousMedsController];
        }
    }
}

@end
