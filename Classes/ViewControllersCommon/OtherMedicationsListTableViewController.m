//
//  OtherMedicationsListTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/09/2013.
//
//

#import "OtherMedicationsListTableViewController.h"
#import "ContentContainerViewController.h"
#import "ContentNavigationController.h"
#import "Constants.h"
#import "CoreDataManager.h"
#import "EditOtherMedsTableViewController.h"
#import "OtherMedication+Handling.h"

@interface OtherMedicationsListTableViewController ()
@property (nonatomic, strong) NSArray * otherMediction;
@end

@implementation OtherMedicationsListTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.otherMediction = [NSArray array];//init with empty array
    self.navigationItem.title = NSLocalizedString(@"Other Medication", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)addButtonPressed:(id)sender
{
    EditOtherMedsTableViewController *otherController = [[EditOtherMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];
    [self.navigationController pushViewController:otherController animated:YES];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.otherMediction.count;
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
    OtherMedication *med = (OtherMedication *)[self.otherMediction objectAtIndex:indexPath.row];
    EditOtherMedsTableViewController *otherController = [[EditOtherMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:med hasNumericalInput:NO];
    [self.navigationController pushViewController:otherController animated:YES];
}


#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
    [[CoreDataManager sharedInstance] fetchDataForEntityName:kOtherMedication
                                                   predicate:nil
                                                    sortTerm:kStartDate
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
            self.otherMediction = nil;
            self.otherMediction = [NSArray arrayWithArray:array];
            NSLog(@"we have %d other meds returned", self.otherMediction.count);
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
