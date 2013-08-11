//
//  HamburgerMenuTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 03/08/2013.
//
//

#import "HamburgerMenuTableViewController.h"
#import "ContentContainerViewController.h"
#import <DropboxSDK/DropboxSDK.h>
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
    NSString *controllerName = [self controllerNameForRowIndexPath:indexPath];
    if (nil == controllerName)
    {
        return;
    }
    if ([controllerName isEqualToString:kDropboxController])
    {
        if (![[DBSession sharedSession] isLinked])
        {
            [[DBSession sharedSession] linkFromController:self];
        }
        else
        {
            [(ContentContainerViewController *)self.parentViewController transitionToNavigationControllerWithName:controllerName];            
        }
    }
    else
    {
        [(ContentContainerViewController *)self.parentViewController transitionToNavigationControllerWithName:controllerName];
    }
}

- (void)cancel
{
    [(ContentNavigationController *)self.parentViewController rewindToPreviousController];
}

- (NSString *)controllerNameForRowIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.menus.count)
    {
        return nil;
    }
    NSString *menuName = [self.menus objectAtIndex:indexPath.row];
    if ([menuName isEqualToString:NSLocalizedString(@"Dashboard", nil)])
    {
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Results", nil)])
    {
        return kResultsController;
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"HIV Medication", nil)])
    {
        
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Missed Meds", nil)])
    {
        
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Side Effects", nil)])
    {
        
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Previous Meds", nil)])
    {
        
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Medication Diary", nil)])
    {
        
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Alerts", nil)])
    {
        
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Appointments", nil)])
    {
        
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Other Medication", nil)])
    {
        
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Clinics", nil)])
    {
        
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Procedures", nil)])
    {
        
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Wellness", nil)])
    {
        
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Login Password", nil)])
    {
        
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Backups", nil)])
    {
        return kDropboxController;
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Feedback", nil)])
    {
        
    }
    else if ([menuName isEqualToString:NSLocalizedString(@"Info", nil)])
    {
        
    }
    return nil;
}

@end
