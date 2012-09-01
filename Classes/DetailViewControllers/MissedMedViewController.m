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
#import "MissedMedsDetailTableViewController.h"

@interface MissedMedViewController ()
- (void)loadMissedMedsTableViewController;
@end

@implementation MissedMedViewController

- (IBAction) done:				(id) sender
{
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
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                             target:self action:@selector(done:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(loadMissedMedsTableViewController)];
}

- (void)loadMissedMedsTableViewController
{
    
	MissedMedsDetailTableViewController *newMissedController = [[MissedMedsDetailTableViewController alloc] initWithRecord:self.masterRecord medication:self.allMeds];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newMissedController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
}



- (void)viewDidUnload
{
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
    return [self.allMissedMeds count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0;
}


/**
 gets the string from the medname. This could contain a / 
 */
- (NSString *)getStringFromName:(NSString *)name
{
    NSArray *stringArray = [name componentsSeparatedByString:@"/"];
    NSString *imageName = [(NSString *)[stringArray objectAtIndex:0]lowercaseString];
    return imageName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"SideEffectListCell";
    SideEffectListCell *cell = (SideEffectListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell)
    {
        NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"SideEffectListCell" owner:self options:nil];
        for (id currentObject in cellObjects)
        {
            if ([currentObject isKindOfClass:[SideEffectListCell class]])
            {
                cell = (SideEffectListCell *)currentObject;
                break;
            }
        }  
    }
    MissedMedication *missed = (MissedMedication *)[self.allMissedMeds objectAtIndex:indexPath.row];
	NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	formatter.dateFormat = @"dd MMM YYYY";
    [[cell effect]setText:[formatter stringFromDate:missed.MissedDate]];
    [[cell drug]setText:missed.Name];
    [[cell effectsImageView]setImage:[UIImage imageNamed:@"missed.png"]];
    
    return cell;
}


#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MissedMedication *missed = (MissedMedication *)[self.allMissedMeds objectAtIndex:indexPath.row];
	MissedMedsDetailTableViewController *newMissedController = [[MissedMedsDetailTableViewController alloc] initWithMissedMeds:missed masterRecord:self.masterRecord];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newMissedController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
}

@end