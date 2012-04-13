//
//  ClinicAddTableViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 18/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ClinicAddTableViewController.h"
#import "GeneralSettings.h"
#import "Contacts.h"
#import "iStayHealthyRecord.h"
#import "Utilities.h"

@implementation ClinicAddTableViewController
@synthesize record, contacts;
@synthesize name,idString,www,email,number,emergencynumber, isInChangeMode;

- (id)initWithRecord:(iStayHealthyRecord *)masterrecord{
    self = [super initWithNibName:@"ClinicAddTableViewController" bundle:nil];
    if (self) {
        self.record = masterrecord;
        self.name = @"";
        self.idString = @"";
        self.www = @"";
        self.emergencynumber = @"";
        self.number = @"";
        self.email = @"";
        self.isInChangeMode = NO;
    }
    return self;
}

- (id)initWithContacts:(Contacts *)_contacts WithRecord:(iStayHealthyRecord *)masterrecord
{
    self = [super initWithNibName:@"ClinicAddTableViewController" bundle:nil];
    if (self) {
        self.record = masterrecord;
        self.contacts = _contacts;
        self.isInChangeMode = YES;
        self.name = self.contacts.ClinicName;
        self.idString = self.contacts.ClinicID;
        self.www = self.contacts.ClinicWebSite;
        self.email = self.contacts.ClinicEmailAddress;
        self.number = self.contacts.ClinicContactNumber;
        self.emergencynumber = self.contacts.EmergencyContactNumber;
    }
    return self;
}

- (void)dealloc{
    /*
	[record release];
    [idString release];
    [name release];
    [www release];
    [email release];
    [number release];
    [emergencynumber release];
    [contacts release];
     */
    self.idString = nil;
    self.name = nil;
    self.www = nil;
    self.email = nil;
    self.emergencynumber = nil;
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
    if (self.isInChangeMode) {
        self.navigationItem.title = NSLocalizedString(@"Edit Clinic",nil);
        
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemTrash 
                                                  target:self action:@selector(showAlertView:)] autorelease];
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
                                                   initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                   target:self action:@selector(saveEditedEntry:)] autorelease];	
    }
    else{
        self.navigationItem.title = NSLocalizedString(@"Add Clinic",nil);
        
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                  target:self action:@selector(cancel:)] autorelease];
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
                                                   initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                                   target:self action:@selector(saveNewEntry:)] autorelease];	
    }
}

/**
 shows the Alert view when user clicks the Trash button
 */
- (IBAction) showAlertView:			(id) sender{
    UIAlertView *alert = [[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Delete?", @"Delete?") message:NSLocalizedString(@"Do you want to delete this entry?", @"Do you want to delete this entry?") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"Yes", @"Yes"), nil]autorelease];
    
    [alert show];    
}

/**
 if user really wants to delete the entry call removeSQLEntry
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:NSLocalizedString(@"Yes", @"Yes")]) {
        [self removeSQLEntry];
    }
}

- (void) removeSQLEntry{
    [record removeContactsObject:contacts];
    NSManagedObjectContext *context = [contacts managedObjectContext];
    [context deleteObject:contacts];
    NSError *error = nil;
    if (![context save:&error]) {
#ifdef APPDEBUG
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
        abort();
    }
    [self dismissModalViewControllerAnimated:YES];    
}

- (IBAction) saveNewEntry:			(id) sender{
    NSManagedObjectContext *context = [record managedObjectContext];
    Contacts *contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contacts" inManagedObjectContext:context];
    [record addContactsObject:contact];
    record.UID = [Utilities GUID];
    contact.ClinicName = self.name;
    contact.ClinicID = self.idString;
    contact.ClinicWebSite = self.www;
    contact.ClinicEmailAddress = self.email;
    contact.ClinicContactNumber = self.number;
    contact.EmergencyContactNumber = self.emergencynumber;        
    contact.UID = [Utilities GUID];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }        
    [self dismissModalViewControllerAnimated:YES];    
}

- (IBAction) saveEditedEntry:       (id) sender{
    NSManagedObjectContext *context = [contacts managedObjectContext];
    record.UID = [Utilities GUID];
    contacts.ClinicName = self.name;
    contacts.ClinicID = self.idString;
    contacts.ClinicWebSite = self.www;
    contacts.ClinicEmailAddress = self.email;
    contacts.ClinicContactNumber = self.number;
    contacts.EmergencyContactNumber = self.emergencynumber;        
    contacts.UID = [Utilities GUID];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }            
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction) cancel:				(id) sender{
    [self dismissModalViewControllerAnimated:YES];    
}


#pragma mark - ClinicAddressCellDelegate Protocol implementation
- (void)setValueString:(NSString *)valueString withTag:(int)tag{
    switch (tag) {
        case 0:
            self.name = valueString;
            break;
        case 1:
            self.idString = valueString;
            break;
        case 2:
            self.www = valueString;
            break;
        case 3:
            self.email = valueString;
            break;
        case 4:
            self.number = valueString;
            break;
        case 5:
            self.emergencynumber = valueString;
            break;
    }
}

- (void)setUnitString:(NSString *)unitString{
    //do nothing unit is not needed for these types of cells
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 48.0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (0 == section) {
        return NSLocalizedString(@"Clinic Details", @"Clinic Details");
    }
    else{
        return NSLocalizedString(@"Phone Numbers", @"Phone Numbers");        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"ClinicAddressCell";
    ClinicAddressCell *cell = (ClinicAddressCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell) {
        NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"ClinicAddressCell" owner:self options:nil];
        for (id currentObject in cellObjects) {
            if ([currentObject isKindOfClass:[ClinicAddressCell class]]) {
                cell = (ClinicAddressCell *)currentObject;
                break;
            }
        } 
        [cell setDelegate:self];
    }
    int row = indexPath.row;
    switch (row) {
        case 0:
            [[cell title]setText:NSLocalizedString(@"Clinic", @"Clinic")];
            if (self.isInChangeMode && ![self.name isEqualToString:@""]) {
                [[cell valueField]setText:self.name];
                [[cell valueField]setTextColor:[UIColor blackColor]];
            }
            else{
                [[cell valueField]setText:NSLocalizedString(@"Enter Name", @"Enter Name")];
                [[cell valueField]setTextColor:[UIColor lightGrayColor]];                
            }
                
            break;
        case 1:
            [[cell title]setText:NSLocalizedString(@"Clinic ID", @"Clinic ID")];
            if (self.isInChangeMode && ![self.idString isEqualToString:@""]) {
                [[cell valueField]setText:self.idString];
                [[cell valueField]setTextColor:[UIColor blackColor]];                
            }
            else{
                [[cell valueField]setText:NSLocalizedString(@"Your ID", @"Your ID")];
                [[cell valueField]setTextColor:[UIColor lightGrayColor]];                
            }
            break;
        case 2:
            [[cell title]setText:NSLocalizedString(@"Web", @"Web")];
            [[cell valueField]setKeyboardType:UIKeyboardTypeURL];
            if (self.isInChangeMode && ![self.www isEqualToString:@""]) {
                [[cell valueField]setText:self.www];
                [[cell valueField]setTextColor:[UIColor blackColor]];                
            }
            else{
                [[cell valueField]setText:NSLocalizedString(@"http://www...", @"http://www...")];
                [[cell valueField]setTextColor:[UIColor lightGrayColor]];
            }
            break;
        case 3:
            [[cell title]setText:NSLocalizedString(@"Email", @"Email")];
            [[cell valueField]setKeyboardType:UIKeyboardTypeEmailAddress];
            if (self.isInChangeMode && ![self.email isEqualToString:@""]) {
                [[cell valueField]setText:self.email];
                [[cell valueField]setTextColor:[UIColor blackColor]];                
            }
            else{
                [[cell valueField]setText:NSLocalizedString(@"Clinic email", @"Clinic email")];
                [[cell valueField]setTextColor:[UIColor lightGrayColor]];
            }
            break;
        case 4:
            [[cell title]setText:NSLocalizedString(@"Phone", @"Phone")];
            [[cell valueField]setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
            if (self.isInChangeMode && ![self.number isEqualToString:@""]) {
                [[cell valueField]setText:self.number];
                [[cell valueField]setTextColor:[UIColor blackColor]];                
            }
            else{
                [[cell valueField]setText:NSLocalizedString(@"Enter Number", @"Enter Number")];
                [[cell valueField]setTextColor:[UIColor lightGrayColor]];
            }
            break;
        case 5:
            [[cell title]setText:NSLocalizedString(@"Emergency", @"Emergency")];
            [[cell valueField]setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
            if (self.isInChangeMode && ![self.emergencynumber isEqualToString:@""]) {
                [[cell valueField]setText:self.number];
                [[cell valueField]setTextColor:[UIColor blackColor]];                
            }
            else{
                [[cell valueField]setText:NSLocalizedString(@"Enter Number", @"Enter Number")];
                [[cell valueField]setTextColor:[UIColor lightGrayColor]];
            }
            break;
    }
    [cell setTag:row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    
}

@end
