//
//  ClinicTableViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 09/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ClinicTableViewController.h"
#import "iStayHealthyRecord.h"
#import "GeneralSettings.h"
#import "NSArray-Set.h"
#import "Contacts.h"
#import "ClinicAddTableViewController.h"
#import "ClinicChangeViewController.h"
#import "MedicationCell.h"

@implementation ClinicTableViewController
@synthesize contacts;

/**
 dealloc
 */
- (void)dealloc {
    [super dealloc];
    [contacts release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.title = NSLocalizedString(@"Clinics", @"Clinics");
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                              target:self action:@selector(done:)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(loadClinicAddViewController)]autorelease];
;
}

#pragma mark - actionsheet handling
- (void) showActionSheetForContact:(Contacts *)contact{
    NSString *edit = NSLocalizedString(@"Edit", @"Edit");
    NSString *clinicNumber = contact.ClinicContactNumber;
    NSString *resultsNumber = contact.ResultsContactNumber;
    NSString *appointmentNumber = contact.AppointmentContactNumber;
    NSString *insuranceNumber = contact.InsuranceContactNumber;
    NSString *name = contact.ClinicName;
    
    UIActionSheet *contactSheet = [[[UIActionSheet alloc]initWithTitle:name delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:edit otherButtonTitles:clinicNumber,resultsNumber,appointmentNumber,insuranceNumber, nil]autorelease];
    contactSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [contactSheet showInView:self.view];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self loadClinicChangeViewController];
    } else if (buttonIndex == 1) {
    } else if (buttonIndex == 2) {
    } else if (buttonIndex == 3) {
    }
}


- (void)loadClinicAddViewController{
    ClinicAddTableViewController *newClinicController = [[ClinicAddTableViewController alloc] initWithRecord:self.masterRecord];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newClinicController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release];
    [newClinicController release];
}

- (void)loadClinicChangeViewController{
    ClinicChangeViewController *changeController = [[ClinicChangeViewController alloc]initWithContacts:(Contacts *)[contacts objectAtIndex:selectedRow] WithRecord:masterRecord];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:changeController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release];  
    [changeController release];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	NSSet *contactSet = masterRecord.contacts;
	if (0 != [contactSet count]) {
		self.contacts = [NSArray arrayByOrderingSet:contactSet byKey:@"ClinicName" ascending:YES reverseOrder:NO];
	}
	else {
		self.contacts = (NSMutableArray *)contactSet;
	}
	[self.tableView reloadData];
}

/**
 dismiss view without saving
 @id
 */
- (IBAction) done: (id) sender{
	[self dismissModalViewControllerAnimated:YES];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MedicationCell *cell = (MedicationCell *)[tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    if (cell == nil) {
        cell = [[[MedicationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContactCell"] autorelease];
    }    
    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Contacts *contact = (Contacts *)[self.contacts objectAtIndex:indexPath.row];
    cell.nameLabel.text = contact.ClinicName;
    cell.drugLabel.text = contact.ClinicContactNumber;
    cell.imageView.image = [UIImage imageNamed:@"clinic.png"];
    
    return (UITableViewCell *)cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRow = indexPath.row;
    Contacts *contact = (Contacts *)[self.contacts objectAtIndex:indexPath.row];
    [self showActionSheetForContact:contact];
}



@end
