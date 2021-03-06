//
//  OtherMedicationsListTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/09/2013.
//
//

#import "OtherMedicationsListTableViewController.h"
#import "Constants.h"
#import "EditOtherMedsTableViewController.h"
#import "OtherMedication+Handling.h"
#import "DateView.h"
#import "UILabel+Standard.h"
#import "iStayHealthy-Swift.h"


@interface OtherMedicationsListTableViewController ()
@property (nonatomic, strong) NSArray *otherMediction;
@end

@implementation OtherMedicationsListTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.otherMediction = [NSArray array];     // init with empty array
    [self setTitleViewWithTitle:NSLocalizedString(@"Other Medication", nil)];
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
    [self configureCell:cell indexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    NSArray *subviews = cell.contentView.subviews;

    [subviews enumerateObjectsUsingBlock: ^(UIView *view, NSUInteger index, BOOL *stop) {
         [view removeFromSuperview];
     }];
    OtherMedication *med = [self.otherMediction objectAtIndex:indexPath.row];
    CGFloat rowHeight = [self tableView:self.tableView heightForRowAtIndexPath:indexPath] - 2;
    DateView *dateView = [DateView viewWithDate:med.StartDate frame:CGRectMake(20, 1, rowHeight, rowHeight)];

    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 1, 120, rowHeight / 2)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = med.Name;
    nameLabel.textAlignment = NSTextAlignmentJustified;
    nameLabel.textColor = TEXTCOLOUR;
    nameLabel.font = [UIFont systemFontOfSize:15];

    UILabel *doseLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 1 + rowHeight / 2, 120, rowHeight / 2)];
    NSString *dose = [NSString stringWithFormat:@"%3.2f %@", [med.Dose floatValue], med.Unit];
    doseLabel.backgroundColor = [UIColor clearColor];
    doseLabel.text = dose;
    doseLabel.textColor = DARK_RED;
    doseLabel.textAlignment = NSTextAlignmentJustified;
    doseLabel.font = [UIFont systemFontOfSize:10];



    [cell.contentView addSubview:dateView];
    [cell.contentView addSubview:nameLabel];
    [cell.contentView addSubview:doseLabel];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UITableViewCellEditingStyleDelete == editingStyle)
    {
        self.markedIndexPath = indexPath;
        self.markedObject = [self.otherMediction objectAtIndex:indexPath.row];
        [self showDeleteAlertView];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OtherMedication *med = (OtherMedication *) [self.otherMediction objectAtIndex:indexPath.row];
    EditOtherMedsTableViewController *otherController = [[EditOtherMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:med hasNumericalInput:NO];

    [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
    [self.navigationController pushViewController:otherController animated:YES];
}

#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
    PWESPersistentStoreManager *manager = [PWESPersistentStoreManager defaultManager];

    [manager fetchData:kOtherMedication
             predicate:nil
              sortTerm:kStartDate
             ascending:NO completion: ^(NSArray *array, NSError *error) {
         if (nil == array)
         {
             [PWESAlertHandler.alertHandler showAlertViewWithCancelButton:NSLocalizedString(@"Cancel", nil) message:NSLocalizedString(@"Error loading data", nil) presentingController:self];
         }
         else
         {
             self.otherMediction = nil;
             self.otherMediction = [NSArray arrayWithArray:array];
             [self.tableView reloadData];
         }
     }];
}

- (void)handleStoreChanged:(NSNotification *)notification
{
    [self reloadSQLData:notification];
}

@end
