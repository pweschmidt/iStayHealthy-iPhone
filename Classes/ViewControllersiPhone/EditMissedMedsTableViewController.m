//
//  EditMissedMedsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/09/2013.
//
//

#import "EditMissedMedsTableViewController.h"
#import "Constants.h"
#import "CoreDataManager.h"
#import "MissedMedication+Handling.h"
#import "Medication+Handling.h"
#import "Utilities.h"
#import "UILabel+Standard.h"

@interface EditMissedMedsTableViewController ()
@property (nonatomic, strong) NSArray *editMenu;
@property (nonatomic, strong) NSArray *unitArray;
@property (nonatomic, strong) NSArray *currentMeds;
@property (nonatomic, strong) NSMutableArray *titleStrings;
@property (nonatomic, strong) UITableViewCell *selectedReasonCell;
@property (nonatomic, strong) NSMutableDictionary *selectedMedCells;
@end

@implementation EditMissedMedsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
        currentMeds:(NSArray *)currentMeds
      managedObject:(NSManagedObject *)managedObject
{
    self = [super initWithStyle:style
                  managedObject:managedObject
              hasNumericalInput:NO];
    if (nil != self)
    {
        if (nil == currentMeds)
        {
            _currentMeds = [NSArray array];
        }
        else
        {
            _currentMeds = currentMeds;
        }
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"New Missed Medication", nil);
    self.editMenu = @[kMissedReasonForgotten,
                      kMissedReasonNoMeds,
                      kMissedReasonUnable,
                      kMissedReasonUnwilling,
                      kMissedReasonOther];
    self.selectedReasonCell = nil;
    self.selectedMedCells = [NSMutableDictionary dictionary];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setDefaultValues
{
    if(!self.isEditMode)
    {
        return;
    }
}

- (void)save:(id)sender
{
    if (nil == self.selectedReasonCell)
    {
        return;
    }
    if (0 == self.currentMeds.count)
    {
    }
    MissedMedication *med = nil;
    if (self.isEditMode)
    {
        med = (MissedMedication *)self.managedObject;
    }
    else
    {
        med = [[CoreDataManager sharedInstance] managedObjectForEntityName:kMissedMedication];
    }
    med.UID = [Utilities GUID];
    med.MissedDate = self.date;
    NSError *error = nil;
    [[CoreDataManager sharedInstance] saveContext:&error];
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        return ([self indexPathHasPicker:indexPath] ? kBaseDateCellRowHeight : self.tableView.rowHeight);
    }
    else
    {
        return 60;
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        if ([self hasInlineDatePicker])
        {
            // we have a date picker, so allow for it in the number of rows in this section
            NSInteger numRows = self.editMenu.count + 1;
            return ++numRows;
        }
        return self.editMenu.count + 1;
    }
    else
    {
        return self.currentMeds.count;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = nil;
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            identifier = [NSString stringWithFormat:kBaseDateCellRowIdentifier];
        }
        else
        {
            if ([self hasInlineDatePicker])
            {
                identifier = [NSString stringWithFormat:@"DatePickerCell"];
            }
            else
            {
                identifier = [NSString stringWithFormat:@"MissedReasonCell%d",indexPath.row];
            }
        }
    }
    else
    {
        identifier = [NSString stringWithFormat:@"CurrentMedCell%d", indexPath.row];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            [self configureDateCell:cell indexPath:indexPath dateType:DateOnly];
        }
        else
        {
            if ([self hasInlineDatePicker])
            {
//                [self configureDatePickerCell:cell indexPath:indexPath];
            }
            else
            {
                NSUInteger titleIndex = (nil == self.datePickerIndexPath) ? indexPath.row - 1 : indexPath.row - 2;
                NSString *localisedText = NSLocalizedString([self.editMenu objectAtIndex:titleIndex], nil);
                [self configureCell:cell text:localisedText indexPath:indexPath];
            }
        }
    }
    else
    {
        Medication *current = (Medication *)[self.currentMeds objectAtIndex:indexPath.row];
        [self configureMedCell:cell med:current indexPath:indexPath];
    }
    return cell;
}


- (void)configureCell:(UITableViewCell *)cell
                 text:(NSString *)text
            indexPath:(NSIndexPath *)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    UILabel *label = [UILabel standardLabel];
    label.frame = CGRectMake(20, 0, 200, self.tableView.rowHeight);
    label.text = text;
    [cell.contentView addSubview:label];
}

- (void)configureMedCell:(UITableViewCell *)cell
                     med:(Medication *)med
               indexPath:(NSIndexPath *)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    NSNumber *checked = [self.selectedMedCells objectForKey:indexPath];
    if (!checked)
    {
        [self.selectedMedCells setObject:(checked = [NSNumber numberWithBool:NO])
                                  forKey:indexPath];
    }
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.frame = CGRectMake(20, 2, 55, 55);
    NSString *pathName = [Utilities imageNameFromMedName:med.Name];
    if (nil != pathName)
    {
        NSString *pillPath = [[NSBundle mainBundle]
                              pathForResource:[pathName lowercaseString] ofType:@"png"];
        imageView.image = [UIImage imageWithContentsOfFile:pillPath];
    }
    
    UILabel *label = [UILabel standardLabel];
    label.text = med.Name;
    label.frame = CGRectMake(80, 0, 180, self.tableView.rowHeight);
    
    [cell.contentView addSubview:imageView];
    [cell.contentView addSubview:label];
}

- (void) deselect: (id) sender
{
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (0 == indexPath.section)
    {
        NSInteger titleIndex = (nil == self.datePickerIndexPath) ? indexPath.row - 1 : indexPath.row - 2;
        if (![self hasInlineDatePicker] && 0 <= titleIndex)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.selectedReasonCell = cell;
            [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
        }
    }
    else
    {
        BOOL keyValue = [[self.selectedMedCells objectForKey:indexPath] boolValue];
        BOOL isChecked = !keyValue;
        NSNumber *checked = [NSNumber numberWithBool:isChecked];
        [self.selectedMedCells setObject:checked forKey:indexPath];
        cell.accessoryType = isChecked ? UITableViewCellAccessoryCheckmark :  UITableViewCellAccessoryNone;
        [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
    }
}
@end
