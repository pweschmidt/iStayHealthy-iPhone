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
#import "DateView.h"

@interface MissedMedicationsTableViewController ()
@property (nonatomic, strong) NSArray * missed;
@property (nonatomic, strong) NSArray *currentMeds;
@end

@implementation MissedMedicationsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.missed = [NSArray array];
    self.currentMeds = [NSArray array];
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
    EditMissedMedsTableViewController *controller = [[EditMissedMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped currentMeds:self.currentMeds managedObject:nil];
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UITableViewCellEditingStyleDelete == editingStyle)
    {
        self.markedIndexPath = indexPath;
        self.markedObject = [self.missed objectAtIndex:indexPath.row];
        [self showDeleteAlertView];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MissedMedication *missed = (MissedMedication *)[self.missed objectAtIndex:indexPath.row];
    EditMissedMedsTableViewController *controller = [[EditMissedMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped currentMeds:self.currentMeds managedObject:missed];
    [self.navigationController pushViewController:controller animated:YES];
    
}


#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
    [[CoreDataManager sharedInstance] fetchDataForEntityName:kMissedMedication predicate:nil sortTerm:kMissedDate ascending:NO completion:^(NSArray *array, NSError *error) {
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
            [[CoreDataManager sharedInstance] fetchDataForEntityName:kMedication predicate:nil sortTerm:kStartDate ascending:NO completion:^(NSArray *medsarray, NSError *innererror) {
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
                    self.currentMeds = nil;
                    self.currentMeds = [NSArray arrayWithArray:medsarray];
                    [self.tableView reloadData];
                }
            }];
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
