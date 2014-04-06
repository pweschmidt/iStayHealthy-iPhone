//
//  BaseEditTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/09/2013.
//
//

#import "BaseEditTableViewController.h"
#import "Utilities.h"
#import "NSDate+Extras.h"
#import "UIFont+Standard.h"
#import "CoreDataManager.h"

#define kContentOffsetX 20.0f
#define kLabelWidthIPhone 100.0f
#define kLabelWidthiPad   160.0f
#define kLabelWidthReductioniPhone 140.0f
#define kLabelWidthReductioniPad    10.0f


@interface BaseEditTableViewController ()
{
	CGFloat labelWidth;
	CGFloat textFieldWidthReduction;
	CGFloat cellWidth;
}
@property (nonatomic, assign) BOOL hasNumericalInput;
@property (nonatomic, assign) DateType dateType;
@end

@implementation BaseEditTableViewController

- (id)  initWithStyle:(UITableViewStyle)style
        managedObject:(NSManagedObject *)managedObject
    hasNumericalInput:(BOOL)hasNumericalInput
{
	self = [super initWithStyle:style];
	if (nil != self)
	{
		_hasNumericalInput = hasNumericalInput;
		_managedObject = managedObject;
		_isEditMode = (nil != managedObject);
		_date = [NSDate date];
		_datePickerIndexPath = nil;
		_dateIsChanged = NO;
		_formatter = [[NSDateFormatter alloc] init];
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	cellWidth = self.tableView.bounds.size.width;
	self.tableView.backgroundColor = DEFAULT_BACKGROUND;
	NSArray *barButtons = nil;
	UIButton *save = [UIButton buttonWithType:UIButtonTypeCustom];
	save.frame = CGRectMake(0, 0, 20, 20);
	save.backgroundColor = [UIColor clearColor];
	[save setBackgroundImage:[UIImage imageNamed:@"save.png"] forState:UIControlStateNormal];
	[save addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithCustomView:save];
	if (self.isEditMode)
	{
		UIBarButtonItem *trashButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(showDeleteAlertView)];
		barButtons = @[saveButton, trashButton];
	}
	else
	{
		barButtons = @[saveButton];
	}
	if ([Utilities isIPad])
	{
		labelWidth = kLabelWidthiPad;
		textFieldWidthReduction = kLabelWidthReductioniPad;
	}
	else
	{
		labelWidth = kLabelWidthIPhone;
		textFieldWidthReduction = kLabelWidthReductioniPhone;
	}
	self.navigationItem.rightBarButtonItems = barButtons;
	self.cellDictionary = [NSMutableDictionary dictionary];
	self.inputTypeForTextView = [NSMutableDictionary dictionary];
}

- (void)didReceiveMemoryWarning
{
	self.cellDictionary = nil;
	[super didReceiveMemoryWarning];
}

- (void)popController
{
	if ([Utilities isIPad])
	{
		if (nil != self.customPopOverDelegate)
		{
			__strong id <PWESPopoverDelegate> strongPopoverDelegate = self.customPopOverDelegate;
			if ([strongPopoverDelegate respondsToSelector:@selector(hidePopover)])
			{
				[strongPopoverDelegate hidePopover];
			}
		}
	}
	else
	{
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void)save:(id)sender
{
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
	                               reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]                                 userInfo:nil];
}

- (void)removeManagedObject
{
	NSManagedObjectContext *defaultContext = [[CoreDataManager sharedInstance] defaultContext];
	[defaultContext deleteObject:self.managedObject];
	NSError *error = nil;
	[[CoreDataManager sharedInstance] saveContextAndWait:&error];
	[self popController];
}

- (void)configureTableCell:(PWESCustomTextfieldCell *)cell
                     title:(NSString *)title
                 indexPath:(NSIndexPath *)indexPath
         hasNumericalInput:(BOOL)hasNumericalInput
{
	[self configureTableCell:cell title:title indexPath:indexPath segmentIndex:indexPath.section hasNumericalInput:hasNumericalInput];
}

- (void)configureTableCell:(PWESCustomTextfieldCell *)cell
                     title:(NSString *)title
                 indexPath:(NSIndexPath *)indexPath
              segmentIndex:(NSInteger)segmentIndex
         hasNumericalInput:(BOOL)hasNumericalInput
{
	NSNumber *taggedViewNumber = [self tagNumberForIndex:indexPath.row segment:segmentIndex];
	cell.contentView.backgroundColor = [UIColor clearColor];
	PWESCustomTextfieldCell *retrievedCell = [self.cellDictionary objectForKey:taggedViewNumber];
	CGRect adjustedCellFrame = CGRectMake(0, 0, cellWidth, cell.contentView.frame.size.height);
	if (nil != retrievedCell)
	{
		[cell clear];
	}
	[cell createContentWithTitle:title
	                textFieldTag:[taggedViewNumber integerValue]
	           textFieldDelegate:self
	           hasNumericalInput:hasNumericalInput
	                contentFrame:adjustedCellFrame];
	[self.cellDictionary setObject:cell forKey:taggedViewNumber];
}

- (void)configureDateCell:(UITableViewCell *)cell
                indexPath:(NSIndexPath *)indexPath
                 dateType:(DateType)dateType
{
	self.dateType = dateType;
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


	UILabel *label = (UILabel *)[cell viewWithTag:kBaseDateLabelTag];
	if (nil == label)
	{
		label = [[UILabel alloc] init];
		label.frame = CGRectMake(50, 0, 200, cell.contentView.frame.size.height);
		label.backgroundColor = [UIColor clearColor];
		label.textColor = TEXTCOLOUR;
		label.tag = kBaseDateLabelTag;
		label.textAlignment = NSTextAlignmentCenter;
		label.font = [UIFont systemFontOfSize:15];
		label.text = [self.formatter stringFromDate:self.date];
		[cell.contentView addSubview:label];
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)configureDatePickerCell:(UITableViewCell *)cell
                      indexPath:(NSIndexPath *)indexPath
{
	cell.contentView.backgroundColor = [UIColor clearColor];

	UIDatePicker *datePicker = [[UIDatePicker alloc] init];
	datePicker.tag = kBaseDateCellTag;
	datePicker.backgroundColor = [UIColor clearColor];
	[self selectDatePickerMode:datePicker];
	[datePicker addTarget:self
	               action:@selector(dateAction:)
	     forControlEvents:UIControlEventValueChanged];
	[cell.contentView addSubview:datePicker];
}

- (UITextField *)customTextFieldForTagNumber:(NSNumber *)tagNumber
{
	if (nil == self.cellDictionary)
	{
		return nil;
	}
	UITextField *textField = nil;
	PWESCustomTextfieldCell *customCell = [self.cellDictionary objectForKey:tagNumber];
	if (nil != customCell)
	{
		textField =  customCell.inputField;
	}
	return textField;
}

- (BOOL)textFieldIsInDictionary:(UITextField *)textField
{
	if (nil == self.cellDictionary)
	{
		return NO;
	}
	__block BOOL isFound = NO;
	[self.cellDictionary enumerateKeysAndObjectsUsingBlock: ^(NSNumber *key, PWESCustomTextfieldCell *cell, BOOL *stop) {
	    if ([textField isEqual:cell.inputField])
	    {
	        isFound = YES;
		}
	}];
	return isFound;
}

- (NSNumber *)tagNumberForIndex:(NSUInteger)index segment:(NSUInteger)segment
{
	NSUInteger tag = pow(10, segment) + index;
	return @(tag);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
	                               reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]                                 userInfo:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
	                               reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]                                 userInfo:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
	                               reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
	                             userInfo:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if ([cell.reuseIdentifier isEqualToString:kBaseDateCellRowIdentifier])
	{
		[self changeDate:indexPath];
	}
	else
	{
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	textField.text = @"";
	textField.textColor = [UIColor blackColor];
//	UIColor *backgroundColour = [UIColor colorWithRed:235.0f / 255.0f green:235.0f / 255.0f blue:235.0f / 255.0f alpha:0.8];

	[UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations: ^{
	    [self.cellDictionary enumerateKeysAndObjectsUsingBlock: ^(id key, PWESCustomTextfieldCell *cell, BOOL *stop) {
	        if (textField != cell.inputField)
	        {
	            [cell shade];
			}
	        else
	        {
	            [cell partialShade];
			}
		}];
	} completion:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations: ^{
	    [self.cellDictionary enumerateKeysAndObjectsUsingBlock: ^(id key, PWESCustomTextfieldCell *cell, BOOL *stop) {
	        [cell unshade];
		}];
	} completion:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSNumber *tagNumber = [NSNumber numberWithInteger:textField.tag];
	BOOL hasNumericalInput = [[self.inputTypeForTextView objectForKey:tagNumber] boolValue];
	if (!hasNumericalInput)
	{
		return YES;
	}

	NSString *separator = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];
	NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
	NSString *expression = nil;

	if ([@"." isEqualToString : separator])
	{
		expression = @"^([0-9]{1,9})?(\\.([0-9]{1,2})?)?$";
	}
	else
	{
		expression = @"^([0-9]{1,9})?(,([0-9]{1,2})?)?$";
	}

	NSError *error = nil;

	NSRegularExpression *regex = [NSRegularExpression
	                              regularExpressionWithPattern:expression
	                                                   options:NSRegularExpressionCaseInsensitive
	                                                     error:&error];
	if (error)
	{
		return YES;
	}
	NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
	                                                    options:0
	                                                      range:NSMakeRange(0, [newString length])];

	if (0 < numberOfMatches)
	{
		return YES;
	}
	return NO;
}

#pragma UIAlertViewDelegate methods

- (void)showDeleteAlertView
{
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Delete?", @"Delete?") message:NSLocalizedString(@"Do you want to delete this entry?", @"Do you want to delete this entry?") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"Yes", @"Yes"), nil];

	[alert show];
}

/**
   if user really wants to delete the entry call removeSQLEntry
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
	if ([title isEqualToString:NSLocalizedString(@"Yes", @"Yes")])
	{
		[self removeManagedObject];
	}
}

#pragma mark - ActionSheet delegate only used for iOS 6.x
- (void)changeDate:(NSIndexPath *)indexPath
{
	[self.tableView beginUpdates];
	BOOL sameCellClicked = NO;
	if (nil != self.datePickerIndexPath)
	{
		sameCellClicked = (self.datePickerIndexPath.row - 1 == indexPath.row);
	}

	if ([self hasInlineDatePicker])
	{
		UITableViewCell *checkDatePickerCell = [self.tableView
		                                        cellForRowAtIndexPath:self.datePickerIndexPath];
		id view = [checkDatePickerCell viewWithTag:kBaseDateCellTag];
		if (nil != view)
		{
			UIDatePicker *pickerView = (UIDatePicker *)view;
			[pickerView removeFromSuperview];
		}
		[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row inSection:0]]
		                      withRowAnimation:UITableViewRowAnimationFade];
		self.datePickerIndexPath = nil;
	}

	if (!sameCellClicked)
	{
		NSInteger rowToReveal = indexPath.row;
		NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:rowToReveal inSection:0];

		[self revealDatePickerForSelectedIndexPath:indexPathToReveal];
		self.datePickerIndexPath = [NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:0];
	}

	// always deselect the row containing the start or end date
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self.tableView endUpdates];
	[self updateDatePicker];
}

#pragma mark - iOS7 date cell handling
/**
   This code is taken almost verbatim from Apple's sample DateCell project
 */
- (BOOL)hasInlineDatePicker
{
	return (self.datePickerIndexPath != nil);
}

- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath
{
	return ([self hasInlineDatePicker] && self.datePickerIndexPath.row == indexPath.row);
}

- (BOOL)hasPickerForIndexPath:(NSIndexPath *)indexPath
{
	NSInteger targetedRow = indexPath.row;
	targetedRow++;
	UITableViewCell *checkDatePickerCell = [self.tableView
	                                        cellForRowAtIndexPath:[NSIndexPath
	                                                               indexPathForRow:targetedRow
	                                                                     inSection:0]];

	UIDatePicker *datePicker = (UIDatePicker *)[checkDatePickerCell
	                                            viewWithTag:kBaseDateCellTag];
	return (nil != datePicker);
}

- (void)updateDatePicker
{
	if (self.datePickerIndexPath != nil)
	{
		UITableViewCell *checkDatePickerCell = [self.tableView
		                                        cellForRowAtIndexPath:self.datePickerIndexPath];

		UIDatePicker *datePicker = [[UIDatePicker alloc] init];
		datePicker.tag = kBaseDateCellTag;
//        datePicker.datePickerMode = UIDatePickerModeDate;
		[datePicker addTarget:self
		               action:@selector(dateAction:)
		     forControlEvents:UIControlEventValueChanged];
		[checkDatePickerCell.contentView addSubview:datePicker];

		if (nil != datePicker)
		{
			[datePicker setDate:self.date animated:NO];
			[self selectDatePickerMode:datePicker];
		}
	}
}

- (void)revealDatePickerForSelectedIndexPath:(NSIndexPath *)indexPath
{
	[self.tableView beginUpdates];

	NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]];

	// check if 'indexPath' has an attached date picker below it
	if ([self hasPickerForIndexPath:indexPath])
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

- (IBAction)dateAction:(id)sender
{
	UITableViewCell *dateLabelCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	UILabel *label = (UILabel *)[dateLabelCell viewWithTag:kBaseDateLabelTag];
	UIDatePicker *datePicker = (UIDatePicker *)sender;
	self.date = datePicker.date;
	if (nil != label)
	{
		label.text = [self.formatter stringFromDate:datePicker.date];
		self.dateIsChanged = YES;
	}
}

- (void)selectDatePickerMode:(UIDatePicker *)datePicker
{
	switch (self.dateType)
	{
		case DateOnly:
			datePicker.datePickerMode = UIDatePickerModeDate;
			break;

		case DateAndTime:
			datePicker.datePickerMode = UIDatePickerModeDateAndTime;
			break;

		case TimeOnly:
			datePicker.datePickerMode = UIDatePickerModeTime;
			break;
	}
}

- (void)setDateLabelTitle:(UILabel *)label
{
	switch (self.dateType)
	{
		case DateOnly:
			label.text = NSLocalizedString(@"Date", nil);
			break;

		case DateAndTime:
			label.text = NSLocalizedString(@"Date/Time", nil);
			break;

		case TimeOnly:
			label.text = NSLocalizedString(@"Time", nil);
			break;
	}
}

- (void)setDateFormatter
{
	switch (self.dateType)
	{
		case DateOnly:
			self.formatter.dateFormat = kDateFormatting;
			break;

		case DateAndTime:
			self.formatter.dateFormat = kDefaultDateFormatting;
			break;

		case TimeOnly:
			self.formatter.dateFormat = kTimeFormatting;
			break;
	}
}

- (UIImage *)blankImage
{
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(55, 55), NO, 0.0);
	UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return blank;
}

@end
