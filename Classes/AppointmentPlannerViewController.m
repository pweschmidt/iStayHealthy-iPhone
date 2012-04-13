//
//  AppointmentPlannerViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 23/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppointmentPlannerViewController.h"
#import "iStayHealthyRecord.h"
#import "iStayHealthyAppDelegate.h"
#import "NSArray-Set.h"
#import "GeneralSettings.h"
#import "Medication.h"

@implementation AppointmentPlannerViewController
@synthesize record, meds;

- (id)initWithRecord:(iStayHealthyRecord *)masterRecord
{
    self = [super initWithNibName:@"AppointmentPlannerViewController" bundle:nil];
    if (self) {
        self.record = masterRecord;
    }
    return self;
}

- (void)dealloc{
    [record release];
    [meds release];
    meds = nil;
    record = nil;
    [super dealloc];
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
	self.navigationItem.title = NSLocalizedString(@"Plan Appointment",@"Plan Appointment");
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                              target:self action:@selector(cancel:)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                               target:self action:@selector(save:)] autorelease];
	NSSet *medSet = record.medications;
	if (0 != [medSet count]) {
		self.meds = [NSArray arrayByOrderingSet:medSet byKey:@"Name" ascending:YES reverseOrder:NO];
	}
	else {//if array empty - simply map empty set to array
		self.meds = (NSArray *)medSet;
	}
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

- (IBAction) save:					(id) sender{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction) cancel:				(id) sender{
    [self dismissModalViewControllerAnimated:YES];    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (0 == [self.meds count]) {
        return 1;
    }
    else
        return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == [self.meds count]) {
        return 2;
    }
    else{
        if (0 == section) {
            return [self.meds count];
        }
        else if(1 == section){
            return 1;
        }
        else{
            return 2;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
