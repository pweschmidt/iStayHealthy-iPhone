//
//  MyHIVMedicationViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 24/08/2013.
//
//

#import "MyHIVMedicationViewController.h"
// #import "ContentContainerViewController.h"
// #import "ContentNavigationController.h"
#import "Constants.h"
// #import "CoreDataManager.h"
#import "PreviousMedication+Handling.h"
#import "Medication+Handling.h"
#import "EditHIVMedsTableViewController.h"
#import "EditCurrentHIVMedsTableViewController.h"
#import "EditPreviousMedsTableViewController.h"
#import "UILabel+Standard.h"
#import "DateView.h"
#import "Utilities.h"
#import "iStayHealthy-Swift.h"

@interface MyHIVMedicationViewController ()
@property (nonatomic, strong) NSArray *currentMeds;
@property (nonatomic, strong) NSArray *previousMeds;
@end

@implementation MyHIVMedicationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentMeds = [NSArray array];
    self.previousMeds = [NSArray array];
    [self setTitleViewWithTitle:NSLocalizedString(@"HIV Medications", nil)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)addButtonPressed:(id)sender
{
    EditHIVMedsTableViewController *controller = [[EditHIVMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];

    [self.navigationController pushViewController:controller animated:YES];
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
    [self configureCell:cell indexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    NSArray *subviews = cell.contentView.subviews;

    [subviews enumerateObjectsUsingBlock: ^(UIView *view, NSUInteger index, BOOL *stop) {
         [view removeFromSuperview];
     }];
    CGFloat rowHeight = [self tableView:self.tableView heightForRowAtIndexPath:indexPath] - 2;
    UIImageView *medImageView = [[UIImageView alloc] init];
    medImageView.frame = CGRectMake(20 + rowHeight + 170, 1, rowHeight, rowHeight);
    medImageView.backgroundColor = [UIColor clearColor];
    UILabel *label = [UILabel standardLabel];
    label.frame = CGRectMake(20 + rowHeight + 5, 1, 160, rowHeight);
    DateView *dateView = nil;
    if (0 == indexPath.section)
    {
        Medication *med = (Medication *) [self.currentMeds objectAtIndex:indexPath.row];
        dateView = [DateView viewWithDate:med.StartDate
                                    frame:CGRectMake(20, 1, rowHeight, rowHeight)];
        label.text = med.Name;
        UIImage *image = [Utilities imageFromMedName:med.Name];
        if (nil == image)
        {
            image = [self blankImage];
        }
        medImageView.image = image;
    }
    else
    {
        PreviousMedication *med = (PreviousMedication *) [self.previousMeds
                                                          objectAtIndex:indexPath.row];
        dateView = [DateView viewWithDate:med.startDate
                                    frame:CGRectMake(20, 1, rowHeight, rowHeight)];
        label.text = med.name;
        UIImage *image = [Utilities imageFromMedName:med.name];
        if (nil == image)
        {
            image = [self blankImage];
        }
        medImageView.image = image;
    }
    [cell.contentView addSubview:dateView];
    [cell.contentView addSubview:label];
    [cell.contentView addSubview:medImageView];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UITableViewCellEditingStyleDelete == editingStyle)
    {
        self.markedIndexPath = indexPath;
        if (0 == indexPath.section)
        {
            self.markedObject = [self.currentMeds objectAtIndex:indexPath.row];
        }
        else
        {
            self.markedObject = [self.previousMeds objectAtIndex:indexPath.row];
        }
        [self showDeleteAlertView];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        Medication *med = (Medication *) [self.currentMeds objectAtIndex:indexPath.row];
        EditCurrentHIVMedsTableViewController *controller = [[EditCurrentHIVMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:med hasNumericalInput:NO];
        [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
        [self.navigationController pushViewController:controller animated:YES];
    }
    else
    {
        PreviousMedication *med = (PreviousMedication *) [self.previousMeds objectAtIndex:indexPath.row];
        EditPreviousMedsTableViewController *controller = [[EditPreviousMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:med hasNumericalInput:NO];
        [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
#ifdef APPDEBUG
    NSLog(@"MyHIVMedicationViewController with name %@", notification.name);
#endif
    PWESPersistentStoreManager *manager = [PWESPersistentStoreManager defaultManager];
    [manager fetchData:kMedication predicate:nil sortTerm:kStartDate ascending:YES completion: ^(NSArray *array, NSError *error) {
         if (nil == array)
         {
             UIAlertView *errorAlert = [[UIAlertView alloc]
                                        initWithTitle:NSLocalizedString(@"Error", nil)
                                                  message:NSLocalizedString(@"Error loading data", nil)
                                                 delegate:nil
                                        cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                        otherButtonTitles:nil];
             [errorAlert show];
         }
         else
         {
             self.currentMeds = array;
             [manager fetchData:kPreviousMedication predicate:nil sortTerm:kEndDateLowerCase ascending:YES completion: ^(NSArray *prevarray, NSError *error) {
                  if (nil == prevarray)
                  {
                      UIAlertView *errorAlert = [[UIAlertView alloc]
                                                 initWithTitle:NSLocalizedString(@"Error", nil)
                                                           message:NSLocalizedString(@"Error loading data", nil)
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                 otherButtonTitles:nil];
                      [errorAlert show];
                  }
                  else
                  {
                      self.previousMeds = prevarray;
                      [self.tableView reloadData];
                  }
              }];
         }
     }];
}

- (void)handleStoreChanged:(NSNotification *)notification
{
    [self reloadSQLData:notification];
}

@end
