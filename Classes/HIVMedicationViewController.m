//
//  HIVMedicationViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 29/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HIVMedicationViewController.h"
#import "MedicationDetailTableViewController.h"
#import "MedicationChangeTableViewController.h"
#import "iStayHealthyRecord.h"
#import "NSArray-Set.h"
#import "Medication.h"
#import "MissedMedication.h"
#import "GeneralSettings.h"
#import "SideEffectsViewController.h"
#import "MissedMedViewController.h"
#import "HIVMedListCell.h"
#import "HIVMedSupportCell.h"
#import "UINavigationBar-Button.h"

@implementation HIVMedicationViewController


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/**
 dealloc
 */
- (void)dealloc {
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
#ifdef APPDEBUG
    NSLog(@"HIVMedicationViewController viewDidLoad");
#endif
    [super viewDidLoad];

	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(loadMedicationDetailViewController)]autorelease];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (navBar) {
        [navBar addButtonWithImageName:@"hivnavbar.png" withTarget:self withSelector:@selector(gotoPOZ)];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
#ifdef APPDEBUG
    NSLog(@"HIVMedicationViewController viewWillAppear");
#endif
    [super viewWillAppear:animated];
}


/**
 loads the MedicationDetailViewController - to add new Combi therapy
 */
- (void)loadMedicationDetailViewController{
	MedicationDetailTableViewController *newMedsView = [[MedicationDetailTableViewController alloc] initWithRecord:masterRecord];
	newMedsView.record = self.masterRecord;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newMedsView];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release];
    [newMedsView release];
}

/**
 loads the MedicationChangeDetailViewController - to add new Combi therapy
 */
- (void)loadMedicationChangeDetailViewController:(NSIndexPath *)selectedIndexPath{
    Medication *med = (Medication *)[allMeds objectAtIndex:selectedIndexPath.row];    
	MedicationChangeTableViewController *changedMedsView = [[MedicationChangeTableViewController alloc]initWithMasterRecord:self.masterRecord withMedication:med];    
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:changedMedsView];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release];
    [changedMedsView release];
}

- (void)loadSideEffectsController{
    SideEffectsViewController *sideController = [[SideEffectsViewController alloc]initWithRecord:masterRecord];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:sideController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release];
    [sideController release];
}

- (void)loadMissedMedicationsController{
    MissedMedViewController *missedController = [[MissedMedViewController alloc]initWithRecord:masterRecord];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:missedController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release];  
    [missedController release];
}



#pragma mark - Table view data source

/**
 2 sections: the first for the number of current HIV drugs. the second for the number of missed doses (if any)
 @tableView
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

/**
 returns number of rows == number of saved medications
 @tableView
 @section
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (0 == section) {
        return [self.allMeds count];
    }
    else{
        return 2;
    }
}

/**
 cell height can be either 70 (for medication cells) or 48 for the cells listing missed medication dates
 @tableView
 @indexPath
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *title = @"";
    if (0 == section) {
        if (0 < [self.allMeds count]) {
            title = NSLocalizedString(@"Current HIV Treatment",nil);
        }
        else{
            title = NSLocalizedString(@"No HIV Treatment Listed", @"No HIV Treatment Listed");                        
        }
    }
    if (1 == section) {
        title = NSLocalizedString(@"Side Effects/Missed Medication", @"Side Effects/Missed Medication");
    }
    return title;
}

/**
 gets the string from the medname. This could contain a / 
 */
- (NSString *)getStringFromName:(NSString *)name{
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (0 == indexPath.section) {
        NSString *identifier = @"HIVMedListCell";
        HIVMedListCell *cell = (HIVMedListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"HIVMedListCell" owner:self options:nil];
        for (id currentObject in cellObjects) {
            if ([currentObject isKindOfClass:[HIVMedListCell class]]) {
                cell = (HIVMedListCell *)currentObject;
                break;
            }
        }
        Medication *medication = (Medication *)[self.allMeds objectAtIndex:indexPath.row];
        NSDateFormatter *formatter = [[[NSDateFormatter alloc]init]autorelease];
        formatter.dateFormat = @"dd MMM YYYY";
        [[cell date]setText:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Start Date", nil),[formatter stringFromDate:medication.StartDate]]];
        [[cell name]setText:medication.Name];
        [[cell content]setText:medication.Drug];
        NSString *shortenedName = [self getStringFromName:medication.Name];
        NSString *pillPath = [[NSBundle mainBundle] 
                              pathForResource:[shortenedName lowercaseString] ofType:@"png"];
        [[cell imageView]setImage:[UIImage imageWithContentsOfFile:pillPath]];
        return cell;
    }
    if (1 == indexPath.section) {
        NSString *identifier = @"HIVMedSupportCell";
        HIVMedSupportCell *cell = (HIVMedSupportCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"HIVMedSupportCell" owner:self options:nil];
        for (id currentObject in cellObjects) {
            if ([currentObject isKindOfClass:[HIVMedSupportCell class]]) {
                cell = (HIVMedSupportCell *)currentObject;
                break;
            }
        }
        
        int row = indexPath.row;
        switch (row) {
            case 0:
                [[cell imageView] setImage:[UIImage imageNamed:@"sideeffects.png"]];
                [[cell support]setText:NSLocalizedString(@"Side Effects", @"Side Effects")];
                [[cell count]setText:[NSString stringWithFormat:@"%d",[self.allSideEffects count]]];
                if (0 < [self.allSideEffects count]) {
                    [[cell count]setTextColor:DARK_RED];
                }
                break;
            case 1:
                [[cell imageView] setImage:[UIImage imageNamed:@"missed.png"]];
                [[cell support]setText:NSLocalizedString(@"Missed", @"Missed")];
                [[cell count]setText:[NSString stringWithFormat:@"%d",[self.allMissedMeds count]]];
                if (0 < [self.allMissedMeds count]) {
                    [[cell count]setTextColor:DARK_RED];
                }
                break;
        }
        
        return cell;
    }
    
    
    
    return nil;
}
#pragma mark -
#pragma mark Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (0 == indexPath.section) {
        [self loadMedicationChangeDetailViewController:indexPath];
    }
    else{
        if (0 == indexPath.row) {
            [self loadSideEffectsController];
        }
        if(1 == indexPath.row){
            [self loadMissedMedicationsController];
        }
    }
}

@end
