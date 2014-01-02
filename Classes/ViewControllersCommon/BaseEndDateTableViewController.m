//
//  BaseEndDateTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 02/01/2014.
//
//

#import "BaseEndDateTableViewController.h"

@interface BaseEndDateTableViewController ()
@property (nonatomic, assign) DateType endDateType;
@end

@implementation BaseEndDateTableViewController

- (id)initWithStyle:(UITableViewStyle)style
      managedObject:(NSManagedObject *)managedObject
  hasNumericalInput:(BOOL)hasNumericalInput
{
    self = [super initWithStyle:style managedObject:managedObject hasNumericalInput:hasNumericalInput];
    if (nil != self)
    {
        _endDate = nil;
        _endDateIsSet = NO;
        _endDatePath = nil;
    }
    return self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:kEndDateCellRowIdentifier])
    {
        [self changeEndDate:indexPath];
    }
    else
    {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)configureEndDateCell:(UITableViewCell *)cell
                   indexPath:(NSIndexPath *)indexPath
                    dateType:(DateType)dateType
{
    self.endDateType = dateType;
    [self setDateFormatter];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    UILabel *dateLabel = [[UILabel alloc] init];
    dateLabel.backgroundColor = [UIColor clearColor];
    dateLabel.frame = CGRectMake(20, 0, 80, cell.contentView.frame.size.height);
    dateLabel.textColor = TEXTCOLOUR;
    dateLabel.font = [UIFont fontWithType:Standard size:standard];
    dateLabel.textAlignment = NSTextAlignmentLeft;
    [self setDateLabelTitle:dateLabel];
    [cell.contentView addSubview:dateLabel];
    
    
    UILabel *label = (UILabel *)[cell viewWithTag:kEndDateLabelTag];
    if (nil == label)
    {
        label = [[UILabel alloc] init];
        label.frame = CGRectMake(50, 0, 200, cell.contentView.frame.size.height);
        label.backgroundColor = [UIColor clearColor];
        label.textColor = TEXTCOLOUR;
        label.tag = kEndDateLabelTag;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15];
        if (self.endDateIsSet && nil != self.endDate)
        {
            label.text = [self.formatter stringFromDate:self.endDate];
        }
        else
        {
            label.text = NSLocalizedString(@"Treatment not ended", nil);
        }
        [cell.contentView addSubview:label];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (IBAction)endDateAction:(id)sender
{
    NSInteger lastSection = [self.tableView numberOfSections] - 1;
    UITableViewCell *dateLabelCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:lastSection]];
    UILabel *label = (UILabel *)[dateLabelCell viewWithTag:kEndDateLabelTag];
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    self.endDate = datePicker.date;
    if (nil != label)
    {
        label.text = [self.formatter stringFromDate:datePicker.date];
        self.endDateIsSet = YES;
    }
}

- (void)changeEndDate:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    BOOL sameCellClicked = NO;
    NSInteger lastSection = [self.tableView numberOfSections] - 1;
    if (nil != self.endDatePath)
    {
        sameCellClicked = (self.endDatePath.row - 1 == indexPath.row);
    }
    
    if ([self hasInlineEndDatePicker])
    {
        UITableViewCell *checkDatePickerCell = [self.tableView
                                                cellForRowAtIndexPath:self.endDatePath];
        id view = [checkDatePickerCell viewWithTag:kEndDateCellTag];
        if (nil != view)
        {
            UIDatePicker *pickerView = (UIDatePicker *)view;
            [pickerView removeFromSuperview];
        }
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.endDatePath.row
                                                                    inSection:lastSection]]
                              withRowAnimation:UITableViewRowAnimationFade];
        self.endDatePath = nil;
    }
    
    if (!sameCellClicked)
    {
        NSInteger rowToReveal = indexPath.row;
        NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:rowToReveal inSection:lastSection];
        
        [self revealEndDatePickerForSelectedIndexPath:indexPathToReveal];
        self.endDatePath = [NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:lastSection];
    }
    
    // always deselect the row containing the start or end date
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView endUpdates];
    [self updateEndDatePicker];
}


- (void)updateEndDatePicker
{
    if (self.endDatePath != nil)
    {
        UITableViewCell *checkDatePickerCell = [self.tableView
                                                cellForRowAtIndexPath:self.endDatePath];
        
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        datePicker.tag = kEndDateCellTag;
        //        datePicker.datePickerMode = UIDatePickerModeDate;
        [datePicker addTarget:self
                       action:@selector(endDateAction:)
             forControlEvents:UIControlEventValueChanged];
        [checkDatePickerCell.contentView addSubview:datePicker];
        
        if (nil != datePicker)
        {
            [datePicker setDate:self.endDate animated:NO];
            [self selectDatePickerMode:datePicker];
        }
    }
}

- (BOOL)hasInlineEndDatePicker
{
    return (self.endDatePath != nil);
}

- (BOOL)indexPathHasEndDatePicker:(NSIndexPath *)indexPath
{
    return ([self hasInlineEndDatePicker] && self.endDatePath.row == indexPath.row);
}

- (BOOL)hasEndDatePickerForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger targetedRow = indexPath.row;
    targetedRow++;
    NSInteger lastSection = [self.tableView numberOfSections] - 1;
    UITableViewCell *checkDatePickerCell = [self.tableView
                                            cellForRowAtIndexPath:[NSIndexPath
                                                                   indexPathForRow:targetedRow
                                                                   inSection:lastSection]];
    
    UIDatePicker *datePicker = (UIDatePicker *)[checkDatePickerCell
                                                viewWithTag:kEndDateCellTag];
    return (nil != datePicker);
}


- (void)revealEndDatePickerForSelectedIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    
    NSInteger lastSection = [self.tableView numberOfSections] - 1;
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:lastSection]];
    
    // check if 'indexPath' has an attached date picker below it
    if ([self hasEndDatePickerForIndexPath:indexPath])
    {
        // found a picker below it, so remove it
        [self.tableView deleteRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        // didn't find a picker below it, so we should insert it
        [self.tableView insertRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.tableView endUpdates];
}

@end
