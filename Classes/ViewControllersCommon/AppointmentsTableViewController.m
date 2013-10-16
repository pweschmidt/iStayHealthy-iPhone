//
//  AppointmentsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/09/2013.
//
//

#import "AppointmentsTableViewController.h"
#import "EditAppointmentsTableViewController.h"
#import "UILabel+Standard.h"


@interface AppointmentsTableViewController ()
@property (nonatomic, strong) NSArray *appointments;
@end

@implementation AppointmentsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.appointments = [NSArray array];//init with empty array
    [self setTitleViewWithTitle:NSLocalizedString(@"Appointments", nil)];
//    self.navigationItem.title = NSLocalizedString(@"Appointments", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)addButtonPressed:(id)sender
{
    EditAppointmentsTableViewController *controller = [[EditAppointmentsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];
    [self.navigationController pushViewController:controller animated:YES];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.appointments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [self configureCell:cell indexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditAppointmentsTableViewController *controller = [[EditAppointmentsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];
    [self.navigationController pushViewController:controller animated:YES];    
}


#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
}
- (void)startAnimation:(NSNotification *)notification
{
}
- (void)stopAnimation:(NSNotification *)notification
{
}
- (void)handleError:(NSNotification *)notification
{
}

- (void)handleStoreChanged:(NSNotification *)notification
{
}


@end
