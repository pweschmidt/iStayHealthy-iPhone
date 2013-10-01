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

@interface BaseEditTableViewController ()
@property (nonatomic, assign) BOOL hasNumericalInput;
@end

@implementation BaseEditTableViewController

- (id)initWithStyle:(UITableViewStyle)style
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
        _datePickerCellIsShown = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = DEFAULT_BACKGROUND;
    NSArray *barButtons = nil;
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(save:)];
    if (self.isEditMode)
    {
        UIBarButtonItem *trashButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteObject:)];
        barButtons = @[saveButton, trashButton];
    }
    else
    {
        barButtons = @[saveButton];
    }
    self.navigationItem.rightBarButtonItems = barButtons;
    self.contentViewsDictionary = [NSMutableDictionary dictionary];
    self.textViews = [NSMutableDictionary dictionary];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setDefaultValues];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    self.contentViewsDictionary = nil;
    self.textViews = nil;
    [super didReceiveMemoryWarning];
}

- (void)setDefaultValues
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
}

- (void)save:(id)sender
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
}

- (void)deleteObject:(id)sender
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];    
}



- (void)configureTableCell:(UITableViewCell *)cell
                     title:(NSString *)title
                 indexPath:(NSIndexPath *)indexPath
{
    NSNumber *taggedViewNumber = nil;
    if (nil != self.datePickerIndexPath)
    {
        taggedViewNumber = [NSNumber numberWithInteger:(indexPath.row - 2)];
    }
    else
    {
        taggedViewNumber = [NSNumber numberWithInteger:(indexPath.row - 1)];
    }
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    UIView *mainContentView = [self.contentViewsDictionary objectForKey:taggedViewNumber];
    if (nil == mainContentView)
    {
        mainContentView = [[UIView alloc] initWithFrame:cell.contentView.frame];
        mainContentView.backgroundColor = [UIColor whiteColor];
        [self.contentViewsDictionary setObject:mainContentView forKey:taggedViewNumber];
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.frame = CGRectMake(20, 0, 80, cell.contentView.frame.size.height);
    label.text = title;
    label.textColor = TEXTCOLOUR;
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentLeft;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    [mainContentView addSubview:label];
    [cell.contentView addSubview:mainContentView];
    
    UITextField * textField = [self.textViews objectForKey:taggedViewNumber];
    if (nil == textField)
    {
        textField = [[UITextField alloc] init];
        textField.backgroundColor = [UIColor whiteColor];
        textField.tag = [taggedViewNumber integerValue];
        textField.frame = CGRectMake(100, 0, cell.contentView.frame.size.width - 120, cell.contentView.frame.size.height);
        textField.delegate = self;
        textField.font = [UIFont systemFontOfSize:15];
        if (self.hasNumericalInput)
        {
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        }
        else
        {
            textField.keyboardType = UIKeyboardTypeDefault;
        }
        
        textField.returnKeyType = UIReturnKeyDone;
        textField.placeholder = @"Enter Value";
        [self.textViews setObject:textField forKey:taggedViewNumber];
    }
    
    
    [cell.contentView addSubview:textField];
    [cell.contentView bringSubviewToFront:textField];
    
}

- (void)configureDateCell:(UITableViewCell *)cell
                indexPath:(NSIndexPath *)indexPath
{
    cell.contentView.backgroundColor = [UIColor clearColor];
    UIView *mainContentView = [[UIView alloc] initWithFrame:cell.contentView.frame];
    mainContentView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.frame = CGRectMake(20, 0, 44, 44);
    imageView.image = [UIImage imageNamed:@"appointments.png"];
    
    [mainContentView addSubview:imageView];
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(50, 0, 200, cell.contentView.frame.size.height);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = TEXTCOLOUR;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:15];
    label.text = [self.date stringFromCustomDate];
    [mainContentView addSubview:label];
    self.dateLabel = label;
    [cell.contentView addSubview:mainContentView];
}

- (void)configureDatePickerCell:(UITableViewCell *)cell
                      indexPath:(NSIndexPath *)indexPath
{
    cell.contentView.backgroundColor = [UIColor clearColor];
//    UIView *mainContentView = [[UIView alloc] initWithFrame:cell.contentView.frame];
//    mainContentView.backgroundColor = [UIColor whiteColor];
    
	UIDatePicker *datePicker = [[UIDatePicker alloc] init];
	datePicker.tag = kBaseDateCellTag;
	datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.backgroundColor = [UIColor clearColor];
    [datePicker addTarget:self
                   action:@selector(dateAction:)
         forControlEvents:UIControlEventValueChanged];
//    [mainContentView addSubview:datePicker];
//    self.datePickerCellView = mainContentView;
    [cell.contentView addSubview:datePicker];
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
        self.datePickerCellIsShown = !self.datePickerCellIsShown;
        [self changeDate:indexPath];
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
    textField.textColor = [UIColor blackColor];
    UIColor *backgroundColour = [UIColor colorWithRed:235.0f/255.0f green:235.0f/255.0f blue:235.0f/255.0f alpha:0.8];
    
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        /*
        if (nil != self.dateCellView)
        {
            self.dateCellView.backgroundColor = backgroundColour;
        }
        if (nil != self.datePickerIndexPath)
        {
            self.datePickerCellView.backgroundColor = backgroundColour;
        }
         */
        for (NSNumber *tagFieldNumber in self.textViews.allKeys)
        {
            UIView *view = [self.contentViewsDictionary objectForKey:tagFieldNumber];
            if (nil != view)
            {
                view.backgroundColor = backgroundColour;
            }
            if (textField.tag != [tagFieldNumber integerValue])
            {
                UITextField *field = [self.textViews objectForKey:tagFieldNumber];
                if (nil != field)
                {
                    field.backgroundColor = backgroundColour;
                }
            }
        }
    } completion:^(BOOL finished) {
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        /*
        if (nil != self.dateCellView)
        {
            self.dateCellView.backgroundColor = [UIColor whiteColor];
        }
        if (nil != self.datePickerIndexPath)
        {
            self.datePickerCellView.backgroundColor = [UIColor whiteColor];
        }
         */
        for (NSNumber *tagFieldNumber in self.textViews.allKeys)
        {
            UIView *view = [self.contentViewsDictionary objectForKey:tagFieldNumber];
            if (nil != view)
            {
                view.backgroundColor = [UIColor whiteColor];
                view.alpha = 1.0;
            }
            if (textField.tag != [tagFieldNumber integerValue])
            {
                UITextField *field = [self.textViews objectForKey:tagFieldNumber];
                if (nil != field)
                {
                    field.backgroundColor = [UIColor whiteColor];
                    field.alpha = 1.0;
                }
            }
        }
    } completion:^(BOOL finished) {
    }];    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!self.hasNumericalInput)
    {
        return YES;
    }
    
    NSString *separator = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *expression = nil;
    
    if ([@"." isEqualToString:separator])
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

#pragma mark - ActionSheet delegate only used for iOS 6.x
- (void)changeDate:(NSIndexPath *)indexPath
{
    if ([Utilities isIOS7])
    {
        [self changeDate_iOS7:indexPath];
    }
    else
    {
        [self changeDate_iOS6];
    }
}

- (void)changeDate_iOS7:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    BOOL before = NO;   // indicates if the date picker is below "indexPath", help us determine which row to reveal
    if ([self hasInlineDatePicker])
    {
        before = self.datePickerIndexPath.row < indexPath.row;
    }
    
//    BOOL sameCellClicked = (kBaseDateCellRow - 1 == indexPath.row);
    
    // remove any date picker cell if it exists
    if ([self hasInlineDatePicker])
    {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
        self.datePickerIndexPath = nil;
    }
    
    if (self.datePickerCellIsShown)
    {
        // hide the old date picker and display the new one
        NSInteger rowToReveal = (before ? indexPath.row - 1 : indexPath.row);
        NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:rowToReveal inSection:0];
        
        [self revealDatePickerForSelectedIndexPath:indexPathToReveal];
        self.datePickerIndexPath = [NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:0];
    }
    
    // always deselect the row containing the start or end date
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView endUpdates];
}


- (void)changeDate_iOS6
{
    NSString *title = @"\n\n\n\n\n\n\n\n\n\n\n\n" ;
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Set",nil), nil];
	[actionSheet showInView:self.view];
	UIDatePicker *datePicker = [[UIDatePicker alloc] init];
	datePicker.tag = kBaseDateCellTag;
	datePicker.datePickerMode = UIDatePickerModeDate;
	[actionSheet addSubview:datePicker];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	UIDatePicker *datePicker = (UIDatePicker *)[actionSheet viewWithTag:kBaseDateCellTag];
	self.date = datePicker.date;
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
    BOOL hasDatePicker = NO;
    
    NSInteger targetedRow = indexPath.row;
    targetedRow++;
    
    UITableViewCell *checkDatePickerCell =
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:targetedRow
                                                             inSection:0]];
    
    UIDatePicker *checkDatePicker = (UIDatePicker *)[checkDatePickerCell
                                                     viewWithTag:kBaseDateCellTag];
    
    hasDatePicker = (checkDatePicker != nil);
    return hasDatePicker;
}

- (BOOL)indexPathHasDate:(NSIndexPath *)indexPath
{
    BOOL hasDate = NO;
    
    if (indexPath.row == kBaseDateCellRow)
    {
        hasDate = YES;
    }
    return hasDate;
}


- (void)updateDatePicker
{
    if (self.datePickerIndexPath != nil)
    {
        UITableViewCell *associatedDatePickerCell = [self.tableView cellForRowAtIndexPath:self.datePickerIndexPath];
        
        UIDatePicker *targetedDatePicker = (UIDatePicker *)[associatedDatePickerCell viewWithTag:kBaseDateCellTag];
        if (targetedDatePicker != nil)
        {
            // we found a UIDatePicker in this cell, so update it's date value
            //
//            NSDictionary *itemData = self.dataArray[self.datePickerIndexPath.row - 1];
//          [targetedDatePicker setDate:[itemData valueForKey:kDateKey] animated:NO];
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
    NSIndexPath *targetedCellIndexPath = nil;
    
    if ([self hasInlineDatePicker])
    {
        // inline date picker: update the cell's date "above" the date picker cell
        //
        targetedCellIndexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:0];
    }
    else
    {
        // external date picker: update the current "selected" cell's date
        targetedCellIndexPath = [self.tableView indexPathForSelectedRow];
    }
    
    UIDatePicker *targetedDatePicker = sender;
    
    // update our data model
//    NSMutableDictionary *itemData = self.dataArray[targetedCellIndexPath.row];
//    [itemData setValue:targetedDatePicker.date forKey:kDateKey];
    self.date = targetedDatePicker.date;
    self.dateLabel.text = [targetedDatePicker.date stringFromCustomDate];
    // update the cell's date string
}


@end
