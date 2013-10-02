//
//  MissedMedicationsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 21/09/2013.
//
//

#import "MissedMedicationsTableViewController.h"
#import "ContentContainerViewController.h"
#import "ContentNavigationController.h"
#import "Constants.h"
#import "CoreDataManager.h"
#import "EditMissedMedsTableViewController.h"
#import "MissedMedication+Handling.h"

@interface MissedMedicationsTableViewController ()
@property (nonatomic, strong) NSArray * missed;
@end

@implementation MissedMedicationsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.missed = [NSArray array];
    self.navigationItem.title = NSLocalizedString(@"Missed Medication", nil);
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
    EditMissedMedsTableViewController *controller = [[EditMissedMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];
    [self.navigationController pushViewController:controller animated:YES];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.missed.count;
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
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MissedMedication *missed = (MissedMedication *)[self.missed objectAtIndex:indexPath.row];
    EditMissedMedsTableViewController *controller = [[EditMissedMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:missed hasNumericalInput:NO];
    [self.navigationController pushViewController:controller animated:YES];
    
}


#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
    [[CoreDataManager sharedInstance] fetchDataForEntityName:kMissedMedication
                                                   predicate:nil
                                                    sortTerm:kMissedDate
                                                   ascending:NO completion:^(NSArray *array, NSError *error) {
                                                       if (nil == array)
                                                       {
                                                           UIAlertView *errorAlert = [[UIAlertView alloc]
                                                                                      initWithTitle:@"Error"
                                                                                      message:@"Error loading data"
                                                                                      delegate:nil
                                                                                      cancelButtonTitle:@"Cancel"
                                                                                      otherButtonTitles:nil];
                                                           [errorAlert show];
                                                           
                                                       }
                                                       else
                                                       {
                                                           self.missed = nil;
                                                           self.missed = [NSArray arrayWithArray:array];
                                                           [self.tableView reloadData];
                                                       }
                                                   }];
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
