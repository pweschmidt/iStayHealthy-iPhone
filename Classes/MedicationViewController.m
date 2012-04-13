//
//  MedicationViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 04/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MedicationViewController.h"
#import "MedicationDetailTableViewController.h"
#import "MedicationChangeTableViewController.h"
#import "iStayHealthyRecord.h"
#import "NSArray-Set.h"
#import "Medication.h"
#import "MissedMedication.h"
#import "GeneralSettings.h"
#import "DateLabelCell.h"
#import "MedicationCell.h"


@implementation MedicationViewController
@synthesize allMeds, allMissedMedDates/*, headerView*/;


#pragma mark -
#pragma mark View lifecycle

/**
 load/setup view
 */
- (void)viewDidLoad {
    [super viewDidLoad];
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(loadMedicationDetailViewController)];
	self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.tableView.rowHeight = 57.0;
    CGRect pozFrame = CGRectMake(CGRectGetMinX(headerView.bounds)+20, CGRectGetMinY(headerView.bounds)+2, 47.0, 30.0);
    UIButton *pozButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [pozButton setFrame:pozFrame];
    [pozButton setBackgroundImage:[UIImage imageNamed:@"poz75.jpg"] forState:UIControlStateNormal];
    [pozButton addTarget:self action:@selector(loadWebView:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:pozButton];
    /*
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (navBar) {
        CGRect titleFrame = CGRectMake(CGRectGetMinX(navBar.bounds)+223.0, CGRectGetMinY(navBar.bounds)+5.0, 47.0, 30.0);
        UILabel *pozLabel = [[[UILabel alloc]initWithFrame:titleFrame]autorelease];
        [pozLabel setBackgroundColor:[UIColor clearColor]];
        UIImageView *pillView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"poz75.jpg"]]autorelease];
        [pozLabel addSubview:pillView];
        [navBar addSubview:pozLabel];
    }
     */
}

/**
 loads the MedicationDetailViewController - to add new Combi therapy
 */
- (void)loadMedicationDetailViewController{
	MedicationDetailTableViewController *newMedsView = [[MedicationDetailTableViewController alloc] initWithNibName:@"MedicationDetailTableViewController" bundle:nil];
	newMedsView.record = self.masterRecord;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newMedsView];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release];
}

- (void)loadMedicationChangeDetailViewController:(NSIndexPath *)selectedIndexPath{
	MedicationChangeTableViewController *changedMedsView = [[MedicationChangeTableViewController alloc] initWithNibName:@"MedicationChangeTableViewController" bundle:nil];
    changedMedsView.record = self.masterRecord;
    changedMedsView.selectedMedication = (Medication *)[allMeds objectAtIndex:selectedIndexPath.row];

	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:changedMedsView];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release];
}

/**
 view will appear
 @animated
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	NSSet *meds = masterRecord.medications;
	if (0 != [meds count]) {
		self.allMeds = [NSArray arrayByOrderingSet:meds byKey:@"Name" ascending:YES reverseOrder:NO];
	}
	else {//if array empty - simply map empty set to array
		self.allMeds = (NSMutableArray *)meds;
	}
    
    NSSet *missedMeds = masterRecord.missedMedications;
    if (0 != [missedMeds count]) {
        self.allMissedMedDates = [NSArray arrayByOrderingSet:missedMeds byKey:@"MissedDate" ascending:YES reverseOrder:YES];
    }
    else{
        self.allMissedMedDates = (NSMutableArray *)missedMeds;
    }
    
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view data source
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
        return [self.allMissedMedDates count];
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
    if ( 0 == section ) {
        if (0 == [self.allMeds count]) {
            return NSLocalizedString(@"No HIV Treatment Listed",nil);
        }
        else
            return NSLocalizedString(@"Current HIV Drugs",nil);
    }
    else{
        if (0 == [self.allMeds count]) {
            return @"";
        }
        else if(0 < [self.allMissedMedDates count]){
            return NSLocalizedString(@"Missed HIV Medication Dates",nil);
        }
    }
    return @"";
}
/**
 configures the MedicationCell
 @cell
 @indexPath
 */
- (void)configureMedicationCell:(MedicationCell *)cell atRow:(int)row{
	Medication *medication = (Medication *)[self.allMeds objectAtIndex:row];
	NSDateFormatter *formatter = [[[NSDateFormatter alloc]init]autorelease];
	formatter.dateFormat = @"dd MMM YYYY";
	cell.dateLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Start Date", nil),[formatter stringFromDate:medication.StartDate]];
	cell.nameLabel.text = medication.Name;
	cell.drugLabel.text = medication.Drug;
    cell.form.text = medication.MedicationForm;
	NSString *pillPath = [[NSBundle mainBundle] pathForResource:[cell.nameLabel.text lowercaseString] ofType:@"png"];
//	NSString *pillPath = [[NSBundle mainBundle] pathForResource:@"combi-label-small" ofType:@"png"];
	cell.imageView.image = [UIImage imageWithContentsOfFile:pillPath];
    cell.iconView.image = [UIImage imageNamed:@"combi-label-small.png"];
}


- (void)configureMissedMedicationCell:(MedicationCell *)cell atRow:(int)row{
    MissedMedication *missed = (MissedMedication *)[self.allMissedMedDates objectAtIndex:row];
	NSDateFormatter *formatter = [[[NSDateFormatter alloc]init]autorelease];
	formatter.dateFormat = @"dd MMM YYYY";
	cell.dateLabel.text = [NSString stringWithFormat:@"%@ on %@",NSLocalizedString(@"Missed on", nil),[formatter stringFromDate:missed.MissedDate]];
    cell.dateLabel.textColor = DARK_RED;
	cell.nameLabel.text = missed.Name;
	cell.drugLabel.text = missed.Drug;
	NSString *pillPath = [[NSBundle mainBundle] pathForResource:[cell.nameLabel.text lowercaseString] ofType:@"png"];
    //	NSString *pillPath = [[NSBundle mainBundle] pathForResource:@"combi-label-small" ofType:@"png"];
	cell.imageView.image = [UIImage imageWithContentsOfFile:pillPath];    
    cell.iconView.image = [UIImage imageNamed:@"missed-small.png"];
}

/**
 sets up the cells in the table
 @tableView
 @indexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MedicationCell *cell = (MedicationCell *)[tableView dequeueReusableCellWithIdentifier:@"MedicationCell"];
    if (cell == nil) {
        cell = [[[MedicationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MedicationCell"] autorelease];
    }    

    if (0 == indexPath.section) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self configureMedicationCell:cell atRow:indexPath.row];
        
    }
    else{
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self configureMissedMedicationCell:cell atRow:indexPath.row];
    }
    return (UITableViewCell *)cell;
}

#pragma mark -
#pragma mark Table view delegate
/**
 only deletion is enabled
 selected med is removed from the table and the database
 @tableView
 @editingStyle
 @indexPath
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (0 == indexPath.section) {
            Medication *meds = (Medication *)[self.allMeds objectAtIndex:indexPath.row];
            [masterRecord removeMedicationsObject:meds];
            [self.allMeds removeObject:meds];
            NSManagedObjectContext *context = meds.managedObjectContext;
            [context deleteObject:meds];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            NSError *error = nil;
            if (![context save:&error]) {
#ifdef APPDEBUG
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
                abort();
            }
        }
        else if(1 == indexPath.section){
            MissedMedication *missed = (MissedMedication *)[self.allMissedMedDates objectAtIndex:indexPath.row];
            [masterRecord removeMissedMedicationsObject:missed];
            [self.allMissedMedDates removeObject:missed];
            NSManagedObjectContext *context = missed.managedObjectContext;
            [context deleteObject:missed];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            NSError *error = nil;
            if (![context save:&error]) {
#ifdef APPDEBUG
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
                abort();
            }
        }
    }   
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (0 == indexPath.section) {
        [self loadMedicationChangeDetailViewController:indexPath];
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
 unload view
 */
- (void)viewDidUnload {
	[super viewDidUnload];
}

/**
 dealloc
 */
- (void)dealloc {
	[allMeds release];
    [allMissedMedDates release];
    [headerView release];
    
    [super dealloc];
}


@end

