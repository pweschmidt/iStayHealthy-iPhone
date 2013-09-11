//
//  BaseEditTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/09/2013.
//
//

#import "BaseEditTableViewController.h"

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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.contentViewsDictionary = [NSMutableDictionary dictionary];
    self.textViews = [NSMutableDictionary dictionary];
}

- (void)didReceiveMemoryWarning
{
    self.contentViewsDictionary = nil;
    self.textViews = nil;
    [super didReceiveMemoryWarning];
}

- (void)configureTableCell:(UITableViewCell *)cell
                     title:(NSString *)title
                 indexPath:(NSIndexPath *)indexPath
{
    NSNumber *taggedViewNumber = [NSNumber numberWithInteger:indexPath.row];
    
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
        textField.tag = indexPath.row;
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
    
}

#pragma mark - Table view data source

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
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
        expression = @"^([0-9]{1,3})?(\\.([0-9]{1,2})?)?$";
    }
    else
    {
        expression = @"^([0-9]{1,3})?(,([0-9]{1,2})?)?$";
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
- (void)changeDate
{
    NSString *title = @"\n\n\n\n\n\n\n\n\n\n\n\n" ;
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Set",nil), nil];
	[actionSheet showInView:self.view];
	UIDatePicker *datePicker = [[UIDatePicker alloc] init];
	datePicker.tag = 101;
	datePicker.datePickerMode = UIDatePickerModeDate;
	[actionSheet addSubview:datePicker];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	UIDatePicker *datePicker = (UIDatePicker *)[actionSheet viewWithTag:101];
	self.date = datePicker.date;
}

@end
