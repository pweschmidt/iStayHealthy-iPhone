//
//  ProcedureTableViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 19/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ProcedureTableViewController.h"
#import "iStayHealthyRecord.h"
#import "GeneralSettings.h"
#import "NSArray-Set.h"
#import "Procedures.h"
#import "ProcedureAddViewController.h"
#import "ProcedureChangeViewController.h"

@implementation ProcedureTableViewController
@synthesize procedures;

/**
 dealloc
 */
- (void)dealloc {
    [super dealloc];
    [procedures release];
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
	self.navigationItem.title = NSLocalizedString(@"Illness", @"Illness");
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                              target:self action:@selector(done:)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(loadProcedureAddViewController)]autorelease];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	NSSet *procedureSet = masterRecord.procedures;
	if (0 != [procedureSet count]) {
		self.procedures = [NSArray arrayByOrderingSet:procedureSet byKey:@"Date" ascending:YES reverseOrder:YES];
	}
	else {
		self.procedures = (NSMutableArray *)procedureSet;
	}
	[self.tableView reloadData];
}

- (void)loadProcedureAddViewController{
    ProcedureAddViewController *newProcController = [[ProcedureAddViewController alloc] initWithRecord:self.masterRecord];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newProcController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release];  
    [newProcController release];
}

- (void)loadProcedureChangeViewController:(int)row{
    ProcedureChangeViewController *changeProcController = [[ProcedureChangeViewController alloc]
    initWithProcedure:(Procedures *)[self.procedures objectAtIndex:row] withMasterRecord:self.masterRecord];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:changeProcController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release]; 
    [changeProcController release];
}




/**
 dismiss view without saving
 @id
 */
- (IBAction) done: (id) sender{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [procedures count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    Procedures *proc = (Procedures *)[self.procedures objectAtIndex:indexPath.row];
    cell.textLabel.text = proc.Name;
    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self loadProcedureChangeViewController:indexPath.row];
}


@end
