//
//  BaseEditTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/09/2013.
//
//

#import <UIKit/UIKit.h>
#import "GeneralSettings.h"
#import "Constants.h"
#import "AddMenuNavigationDelegate.h"
#import "UIFont+Standard.h"

#define kBaseDateCellTag 99
#define kBaseDateCellRow 0
#define kBaseDatePickerRow 1
#define kBaseDateCellRowHeight 255
#define kBaseDateCellRowIdentifier @"DateSelectionCell"

@interface BaseEditTableViewController : UITableViewController
    <UITextFieldDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) NSMutableDictionary *contentViewsDictionary;
@property (nonatomic, strong) NSMutableDictionary *textViews;
@property (nonatomic, strong) NSMutableDictionary *inputTypeForTextView;
@property (nonatomic, assign) BOOL isEditMode;
@property (nonatomic, assign) BOOL datePickerCellIsShown;
@property (nonatomic, strong) NSManagedObject *managedObject;
@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIView *dateCellView;
@property (nonatomic, strong) UIView *datePickerCellView;
@property (nonatomic, weak) id<AddMenuNavigationDelegate> menuDelegate;

- (id)initWithStyle:(UITableViewStyle)style
      managedObject:(NSManagedObject *)managedObject
  hasNumericalInput:(BOOL)hasNumericalInput;

- (void)configureTableCell:(UITableViewCell *)cell
                     title:(NSString *)title
                 indexPath:(NSIndexPath *)indexPath
         hasNumericalInput:(BOOL)hasNumericalInput;

- (void)configureDateCell:(UITableViewCell *)cell
                indexPath:(NSIndexPath *)indexPath
                 dateType:(DateType)dateType;

- (void)configureDatePickerCell:(UITableViewCell *)cell
                      indexPath:(NSIndexPath *)indexPath;

- (void)save:(id)sender;
- (void)removeManagedObject;
- (void)showDeleteAlertView;

- (void)changeDate:(NSIndexPath *)indexPath;
- (void)setDefaultValues;
- (BOOL)hasInlineDatePicker;
- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath;
- (UIImage *)blankImage;
@end
