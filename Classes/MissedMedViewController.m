//
//  MissedMedViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 19/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MissedMedViewController.h"
#import "iStayHealthyRecord.h"
#import "MissedMedication.h"
#import "NSArray-Set.h"
#import "GeneralSettings.h"
#import "SideEffectListCell.h"

@implementation MissedMedViewController
@synthesize record, missedMeds;

- (id)initWithRecord:(iStayHealthyRecord *)masterrecord
{
    self = [super initWithNibName:@"MissedMedViewController" bundle:nil];
    if (self) {
        self.record = masterrecord;
        NSSet *missedSet = record.missedMedications;
        if (0 != [missedSet count]) {
            self.missedMeds = [NSArray arrayByOrderingSet:missedSet byKey:@"MissedDate" ascending:YES reverseOrder:YES];
        }
        else {//if empty - simply map to empty set
            self.missedMeds = (NSMutableArray *)missedSet;
        }    
    }
    return self;
}

- (IBAction) done:				(id) sender{
    [self dismissModalViewControllerAnimated:YES];
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
	self.navigationItem.title = NSLocalizedString(@"Missed", @"Missed");
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                              target:self action:@selector(done:)];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    self.missedMeds = nil;
    [super viewDidUnload];
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
    return [self.missedMeds count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0;
}


/**
 gets the string from the medname. This could contain a / 
 */
- (NSString *)getStringFromName:(NSString *)name{
    NSArray *stringArray = [name componentsSeparatedByString:@"/"];
    NSString *imageName = [(NSString *)[stringArray objectAtIndex:0]lowercaseString];
    return imageName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"SideEffectListCell";
    SideEffectListCell *cell = (SideEffectListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell) {
        NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"SideEffectListCell" owner:self options:nil];
        for (id currentObject in cellObjects) {
            if ([currentObject isKindOfClass:[SideEffectListCell class]]) {
                cell = (SideEffectListCell *)currentObject;
                break;
            }
        }  
    }
    MissedMedication *missed = (MissedMedication *)[self.missedMeds objectAtIndex:indexPath.row];
	NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	formatter.dateFormat = @"dd MMM YYYY";
    [[cell effect]setText:[formatter stringFromDate:missed.MissedDate]];
    [[cell drug]setText:missed.Name];
    [[cell imageView]setImage:[UIImage imageNamed:@"missed.png"]];
    
    return cell;
}


#pragma mark - Table view delegate

/**
 only row deletion is enabled. row is removed and entry is deleted from the database
 @tableView
 @editingStyle
 @indexPath
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete && 0 == indexPath.section) {
		MissedMedication *missed = (MissedMedication *)[self.missedMeds objectAtIndex:indexPath.row];
        [record removeMissedMedicationsObject:missed];
		[self.missedMeds removeObject:missed];
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

@end
