//
//  BaseEndDateTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 02/01/2014.
//
//

#import "BaseEditTableViewController.h"
#define kEndDateCellTag 999
#define kEndDateLabelTag 998
#define kEndDateCellRowIdentifier @"EndDateSelectionCell"

@interface BaseEndDateTableViewController : BaseEditTableViewController
@property (nonatomic, strong) NSIndexPath *endDatePath;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, assign) BOOL endDateIsSet;
@property (nonatomic, assign) NSInteger endDateSection;

- (void)configureEndDateCell:(UITableViewCell *)cell
                   indexPath:(NSIndexPath *)indexPath
                    dateType:(DateType)dateType;
- (BOOL)hasInlineEndDatePicker;
- (BOOL)indexPathHasEndDatePicker:(NSIndexPath *)indexPath;

@end
