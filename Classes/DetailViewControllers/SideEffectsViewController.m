//
//  SideEffectsViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 19/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SideEffectsViewController.h"
#import "iStayHealthyRecord.h"
#import "SideEffects.h"
#import "NSArray-Set.h"
#import "GeneralSettings.h"
#import "SideEffectListCell.h"
#import "SideEffectsDetailTableViewController.h"

@interface SideEffectsViewController()
- (void)loadSideEffectsController;
@end

@implementation SideEffectsViewController



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
	self.navigationItem.title = NSLocalizedString(@"Side Effects", @"Side Effects");
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                              target:self action:@selector(done:)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(loadSideEffectsController)];
    self.tableView.rowHeight = 57.0;
}

- (void)loadSideEffectsController
{
    
	SideEffectsDetailTableViewController *newSideEffectController = [[SideEffectsDetailTableViewController alloc] initWithRecord:self.masterRecord medication:self.allMeds];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newSideEffectController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
}

- (void)updateSideEffectTable
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.allSideEffects count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"SideEffectListCell";
    SideEffectListCell *cell = (SideEffectListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell)
    {
        NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"SideEffectListCell"
                                                            owner:self
                                                          options:nil];
        for (id currentObject in cellObjects)
        {
            if ([currentObject isKindOfClass:[SideEffectListCell class]])
            {
                cell = (SideEffectListCell *)currentObject;
                break;
            }
        }  
    }
    SideEffects *effect = (SideEffects *)[self.allSideEffects objectAtIndex:indexPath.row];
	NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	formatter.dateFormat = @"dd MMM YYYY";
    [[cell date]setText:[formatter stringFromDate:effect.SideEffectDate]];
    [[cell effect]setText:effect.SideEffect];
    [[cell drug]setText:effect.Name];
    [[cell effectsImageView]setImage:[UIImage imageNamed:@"sideeffects.png"]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


#pragma mark - Table view delegate



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SideEffects *effects = (SideEffects *)[self.allSideEffects objectAtIndex:indexPath.row];
	SideEffectsDetailTableViewController *newSideEffectController = [[SideEffectsDetailTableViewController alloc] initWithResults:effects masterRecord:self.masterRecord];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newSideEffectController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
}



@end
