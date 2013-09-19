//
//  MyHIVMedicationViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 24/08/2013.
//
//

#import "MyHIVMedicationViewController.h"
#import "ContentContainerViewController.h"
#import "ContentNavigationController.h"
#import "Constants.h"
#import "CoreDataManager.h"

@interface MyHIVMedicationViewController ()
@property (nonatomic, strong) NSArray * currentMeds;
@property (nonatomic, strong) NSArray * previousMeds;
@end

@implementation MyHIVMedicationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentMeds = [NSArray array];
    self.previousMeds = [NSArray array];
    self.navigationItem.title = NSLocalizedString(@"HIV Medications", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return self.currentMeds.count;
    }
    else
    {
        return self.previousMeds.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (0 == section)
    {
        return NSLocalizedString(@"Current HIV Medications", nil);
    }
    else
    {
        return NSLocalizedString(@"Previous HIV Medications", nil);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MedicationCell";
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
    
}

#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
    NSLog(@"ResultsListTableViewController:reloadSQLData with name %@", notification.name);
    [[CoreDataManager sharedInstance] fetchDataForEntityName:kMedication predicate:nil sortTerm:kStartDate ascending:YES completion:^(NSArray *array, NSError *error) {
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
            self.currentMeds = array;
            [[CoreDataManager sharedInstance] fetchDataForEntityName:kPreviousMedication predicate:nil sortTerm:kEndDateLowerCase ascending:YES completion:^(NSArray *array, NSError *error) {
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
                    self.previousMeds = array;
                    [self.tableView reloadData];
                }
            }];
        }
    }];
}
- (void)startAnimation:(NSNotification *)notification
{
    NSLog(@"MyHIVMedicationViewController:startAnimation with name %@", notification.name);
}
- (void)stopAnimation:(NSNotification *)notification
{
    NSLog(@"MyHIVMedicationViewController:stopAnimation with name %@", notification.name);
}
- (void)handleError:(NSNotification *)notification
{
    NSLog(@"MyHIVMedicationViewController:handleError with name %@", notification.name);
}

- (void)handleStoreChanged:(NSNotification *)notification
{
    NSLog(@"MyHIVMedicationViewController:handleStoreChanged with name %@", notification.name);
    
}

@end
