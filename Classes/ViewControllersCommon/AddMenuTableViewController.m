//
//  AddMenuTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 03/08/2013.
//
//

#import "AddMenuTableViewController.h"
#import "ContentContainerViewController.h"
#import "ContentNavigationController.h"
#import "EditAlertsTableViewController.h"
#import "EditAppointmentsTableViewController.h"
#import "EditHIVMedsTableViewController.h"
#import "EditMissedMedsTableViewController.h"
#import "EditOtherMedsTableViewController.h"
#import "EditResultsTableViewController.h"
#import "EditProceduresTableViewController.h"
#import "EditSideEffectsTableViewController.h"
#import "EditWellnessTableViewController.h"
#import "Menus.h"
@interface AddMenuTableViewController ()
@property (nonatomic, strong) NSArray * menus;
@end

@implementation AddMenuTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = DEFAULT_BACKGROUND;
    self.navigationItem.title = NSLocalizedString(@"Add", nil);
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                             target:self action:@selector(cancel)];
    
    self.menus = [Menus addMenus];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menus.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AddEntryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [self.menus objectAtIndex:indexPath.row];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            EditResultsTableViewController *resultsCtrl = [[EditResultsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:YES];
            resultsCtrl.menuDelegate = self;
            [self.navigationController pushViewController:resultsCtrl animated:YES];
        }
            break;
        case 1:
        {
            EditHIVMedsTableViewController *hivCtrl = [[EditHIVMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            hivCtrl.menuDelegate = self;
            [self.navigationController pushViewController:hivCtrl animated:YES];
        }
            break;
        case 2:
        {
            EditOtherMedsTableViewController *otherCtrl = [[EditOtherMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];
            otherCtrl.menuDelegate = self;
            [self.navigationController pushViewController:otherCtrl animated:YES];
        }
            break;
        case 3:
        {
            EditMissedMedsTableViewController *missedCtrl = [[EditMissedMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];
            missedCtrl.menuDelegate = self;
            [self.navigationController pushViewController:missedCtrl animated:YES];
        }
            break;
        case 4:
        {
            EditSideEffectsTableViewController *effectsCtrl = [[EditSideEffectsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];
            effectsCtrl.menuDelegate = self;
            [self.navigationController pushViewController:effectsCtrl animated:YES];
        }
            break;
        case 5:
        {
            EditAlertsTableViewController *alertsCtrl = [[EditAlertsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];
            alertsCtrl.menuDelegate = self;
            [self.navigationController pushViewController:alertsCtrl animated:YES];
        }
            break;
        case 6:
        {
            EditAppointmentsTableViewController *datesCtrl = [[EditAppointmentsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];
            datesCtrl.menuDelegate = self;
            [self.navigationController pushViewController:datesCtrl animated:YES];
        }
            break;
        case 7:
        {
            EditProceduresTableViewController *procsCtrl = [[EditProceduresTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];
            procsCtrl.menuDelegate = self;
            [self.navigationController pushViewController:procsCtrl animated:YES];
        }
            break;
        case 8:
        {
            EditWellnessTableViewController *wellCtrl = [[EditWellnessTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];
            wellCtrl.menuDelegate = self;
            [self.navigationController pushViewController:wellCtrl animated:YES];
        }
            break;
    }
}

- (void)cancel
{
    [(ContentNavigationController *)self.parentViewController rewindToPreviousController];
}

- (void)moveToNavigationControllerWithName:(NSString *)name
{
    [(ContentNavigationController *)self.parentViewController transitionToNavigationControllerWithName:name];
}


@end
