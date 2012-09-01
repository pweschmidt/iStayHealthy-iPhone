//
//  OtherMedicationViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 10/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OtherMedicationViewController.h"
#import "OtherMedicationDetailViewController.h"
#import "OtherMedicationChangeViewController.h"
#import "iStayHealthyRecord.h"
#import "GeneralSettings.h"
#import "NSArray-Set.h"
#import "OtherMedication.h"
#import "GeneralSettings.h"


@implementation OtherMedicationViewController
@synthesize allMeds/*, headerView*/;



#pragma mark -
#pragma mark View lifecycle

/**
 loads and sets up the view
 */
- (void)viewDidLoad {
    [super viewDidLoad];
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(loadOtherMedicationDetailViewController)];
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
 loads the OtherMedicationDetailViewController to add other non-HIV drugs
 */
- (void)loadOtherMedicationDetailViewController{
	OtherMedicationDetailViewController *newMedsView = [[OtherMedicationDetailViewController alloc] initWithNibName:@"OtherMedicationDetailViewController" bundle:nil];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newMedsView];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
	newMedsView.record = self.masterRecord;
	[navigationController release];
}

- (void)loadOtherMedicationChangeViewController:(int) row{
	OtherMedicationChangeViewController *changeMedsView = [[OtherMedicationChangeViewController alloc] initWithNibName:@"OtherMedicationChangeViewController" bundle:nil];
    changeMedsView.otherMed = (OtherMedication *)[allMeds objectAtIndex:row];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:changeMedsView];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release];
    
}


/**
 loads all the meds just before we present the view
 @animated
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	NSSet *meds = masterRecord.otherMedications;
	if (0 != [meds count]) {
		self.allMeds = [NSArray arrayByOrderingSet:meds byKey:@"Name" ascending:YES reverseOrder:NO];
	}
	else {
		self.allMeds = (NSMutableArray *)meds;
	}

	[self.tableView reloadData];
}



#pragma mark -
#pragma mark Table view data source

/**
 @return 1 section
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/**
 @return number of cells == number of other medications saved
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.allMeds count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 70.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (0 == [self.allMeds count]) {
        return NSLocalizedString(@"No Medications Listed",nil);
    }
    else
        return @"";
}

/**
 sets up the individual MedicationCell
 @cell
 @indexPath
 */
- (void)configureMedicationCell:(MedicationCell *)cell atIndexPath:(NSIndexPath *)indexPath{
	OtherMedication *medication = (OtherMedication *)[self.allMeds objectAtIndex:indexPath.row];
	NSDateFormatter *formatter = [[[NSDateFormatter alloc]init]autorelease];
	formatter.dateFormat = @"dd MMM YYYY";
	cell.dateLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Start Date", nil), [formatter stringFromDate:medication.StartDate]];
	cell.nameLabel.text = medication.Name;
    cell.form.text = [NSString stringWithFormat:@"%@ %d [mg]",NSLocalizedString(@"Dose", nil),[medication.Dose intValue]];   
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	NSString *pillPath = [[NSBundle mainBundle] pathForResource:@"redcross-small" ofType:@"png"];
	cell.imageView.image = [UIImage imageWithContentsOfFile:pillPath];    
}

/**
 loads/sets up table cells
 @tableView
 @indexPath
 @return UITableViewCell
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    MedicationCell *cell = (MedicationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[MedicationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
 	[self configureMedicationCell:cell atIndexPath:indexPath];
    
    return (UITableViewCell *)cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    [self loadOtherMedicationChangeViewController:indexPath.row];
}


#pragma mark -
#pragma mark Table view delegate
/**
 only row deletion allowed. Deletes row and associated entry in data base
 @tableView
 @editingStyle
 @indexPath
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete && 0 == indexPath.section) {
		OtherMedication *meds = (OtherMedication *)[self.allMeds objectAtIndex:indexPath.row];
		[masterRecord removeOtherMedicationsObject:meds];
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
}


#pragma mark -
#pragma mark Memory management
/**
 handles memory warnings
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 unloads view
 */
- (void)viewDidUnload {
	[super viewDidUnload];
}

/**
 dealloc
 */
- (void)dealloc {
	[allMeds release];
//    [headerView release];
    [super dealloc];
}


@end

