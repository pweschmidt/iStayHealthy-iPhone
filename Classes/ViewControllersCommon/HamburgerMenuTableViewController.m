//
//  HamburgerMenuTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 03/08/2013.
//
//

#import "HamburgerMenuTableViewController.h"
#import "ContentContainerViewController.h"
#import "Constants.h"

@interface HamburgerMenuTableViewController ()
@property (nonatomic, strong) NSArray * menus;
@end

@implementation HamburgerMenuTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Menu", nil);
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                             target:self action:@selector(cancel)];
    
    self.menus = @[NSLocalizedString(@"Dashboard", nil),
                   NSLocalizedString(@"Results", nil),
                   NSLocalizedString(@"HIV Medication", nil),
                   NSLocalizedString(@"Missed Meds", nil),
                   NSLocalizedString(@"Side Effects", nil),
                   NSLocalizedString(@"Previous Meds", nil),
                   NSLocalizedString(@"Medication Diary", nil),
                   NSLocalizedString(@"Alerts", nil),
                   NSLocalizedString(@"Appointments", nil),
                   NSLocalizedString(@"Other Medication", nil),
                   NSLocalizedString(@"Clinics", nil),
                   NSLocalizedString(@"Procedures", nil),
                   NSLocalizedString(@"Wellness", nil),
                   NSLocalizedString(@"Login Password", nil),
                   NSLocalizedString(@"Backups", nil),
                   NSLocalizedString(@"Feedback", nil),
                   NSLocalizedString(@"Info", nil)];
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
    static NSString *CellIdentifier = @"SettingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [self.menus objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
//            [(ContentContainerViewController *)self.parentViewController transitionToNavigationControllerWithName:kDashboardController];
            break;
        case 1:
            [(ContentNavigationController *)self.parentViewController transitionToNavigationControllerWithName:kResultsController];
        default:
            break;
    }
}

- (void)cancel
{
    [(ContentNavigationController *)self.parentViewController rewindToPreviousController];
}

@end
