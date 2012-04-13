//
//  NewContactTableViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 15/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NewContactTableViewController.h"
#import "iStayHealthyRecord.h"
#import "Contacts.h"
#import "Utilities.h"

@implementation NewContactTableViewController
@synthesize record, nextAppointmentDate;

- (id)initWithRecord:(iStayHealthyRecord *)masterrecord{
    self = [super initWithNibName:@"OtherMedicationDetailViewController" bundle:nil];
    if (self) {
        self.record = masterrecord;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc{
    [super dealloc];
    [record release];
    [nextAppointmentDate release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.navigationItem.title = NSLocalizedString(@"Add Clinic",nil);
    
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                              target:self action:@selector(cancel:)] autorelease];
    
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                               target:self action:@selector(save:)] autorelease];	
}

/**
 upon save the name of the drug and start date get saved to the data base. view is then dismissed
 @id
 */
- (IBAction) save: (id) sender{
	NSError *error = nil;
	NSManagedObjectContext *context = [record managedObjectContext];
	Contacts *contacts = [NSEntityDescription insertNewObjectForEntityForName:@"Contacts" inManagedObjectContext:context];
	[record addContactsObject:contacts];
    record.UID = [Utilities GUID];
    contacts.UID = [Utilities GUID];
    
	if (![context save:&error]) {
#ifdef APPDEBUG
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
		abort();
	}
	[self dismissModalViewControllerAnimated:YES];
    
}

/**
 dismiss view without saving
 @id
 */
- (IBAction) cancel: (id) sender{
	[self dismissModalViewControllerAnimated:YES];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    return cell;
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
