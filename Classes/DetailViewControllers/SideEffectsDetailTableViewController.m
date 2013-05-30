//
//  SideEffectsDetailTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/08/2012.
//
//

#import "SideEffectsDetailTableViewController.h"
#import "SideEffects.h"
#import "SetDateCell.h"
#import "GeneralSettings.h"
#import "ChartSettings.h"
#import "GradientButton.h"
#import "Utilities.h"
#import "Medication.h"
#import "EffectsListController.h"
#import <QuartzCore/QuartzCore.h>

@interface SideEffectsDetailTableViewController ()
@property BOOL isEditMode;
//@property (nonatomic, strong) NSMutableArray *currentMedArray;
@property (nonatomic, strong) NSString *currentMeds;
@property (nonatomic, strong) UITableViewCell *selectedCell;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) NSNumber *seriousnessIndex;
@property (nonatomic, strong) NSString *selectedSideEffectLabel;
@property (nonatomic, strong) NSString *seriousness;
@property (nonatomic, strong) NSManagedObjectContext *context;
- (void)postNotification;
@end

@implementation SideEffectsDetailTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (id)initWithSideEffects:(SideEffects *)effects
{
    self = [super initWithNibName:@"SideEffectsDetailTableViewController" bundle:nil];
    if (nil != self)
    {
        _isEditMode = YES;
        _context = effects.managedObjectContext;
        _sideEffects = effects;
        _effectsDate = self.sideEffects.SideEffectDate;
        _currentMeds = self.sideEffects.Name;
        _selectedCell = nil;
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.dateFormat = @"dd MMM YY";
        _seriousness = self.sideEffects.seriousness;
        if (nil == _seriousness)
        {
            _seriousnessIndex = [NSNumber numberWithInt:0];
        }
        else
        {
            if ([_seriousness isEqualToString:@"Minor"])
            {
                _seriousnessIndex = [NSNumber numberWithInt:0];
            }
            else if ([_seriousness isEqualToString:@"Major"])
            {
                _seriousnessIndex = [NSNumber numberWithInt:1];
            }
            else
            {
                _seriousnessIndex = [NSNumber numberWithInt:2];
            }
        }
#ifdef APPDEBUG
        NSLog(@"Seriousness is %@",_seriousness);
#endif
    }
    return self;
    
}
- (id)initWithContext:(NSManagedObjectContext *)context medicationName:(NSString *)medicationName
{
    self = [super initWithNibName:@"SideEffectsDetailTableViewController" bundle:nil];
    if (nil != self)
    {
        _context = context;
        _isEditMode = NO;
        _effectsDate = [NSDate date];
        _currentMeds = medicationName;
        _selectedCell = nil;
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.dateFormat = @"dd MMM YY";
        _seriousnessIndex = [NSNumber numberWithInt:0];
    }
    return self;
}

/*
- (id)initWithContext:(NSManagedObjectContext  *)context medications:(NSArray *)medications
{
    self = [super initWithNibName:@"SideEffectsDetailTableViewController" bundle:nil];
    if (nil != self)
    {
        self.context = context;
        self.isEditMode = NO;
        self.effectsDate = [NSDate date];
        self.currentMedArray = [NSMutableArray arrayWithArray:medications];
        NSMutableString *medsString = [NSMutableString string];
        for (Medication *med in self.currentMedArray)
        {
            [medsString appendFormat:@"%@ ",med.Name];
        }
        self.currentMeds = medsString;
        self.selectedCell = nil;
        self.formatter = [[NSDateFormatter alloc] init];
        self.formatter.dateFormat = @"dd MMM YY";
        self.seriousnessIndex = [NSNumber numberWithInt:0];
    }
    return self;
    
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = self.currentMeds;
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                             target:self action:@selector(cancel:)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                              target:self action:@selector(save:)];

    NSArray *segmentArray = [NSArray arrayWithObjects:NSLocalizedString(@"Minor", @"Minor"), NSLocalizedString(@"Major", @"Major"), NSLocalizedString(@"Serious", @"Serious"), nil];
    
    self.seriousnessControl = [[UISegmentedControl alloc] initWithItems:segmentArray];
    
    CGFloat width = self.tableView.bounds.size.width;
    CGFloat segmentWidth = width - 40;
    self.seriousnessControl.frame = CGRectMake(20, 3, segmentWidth, 30);
    self.seriousnessControl.tintColor = TINTCOLOUR;
    self.seriousnessControl.segmentedControlStyle = UISegmentedControlStyleBar;
    self.seriousnessControl.selectedSegmentIndex = [self.seriousnessIndex intValue];
    [self.seriousnessControl addTarget:self action:@selector(seriousnessChanged:) forControlEvents:UIControlEventValueChanged];
}



- (IBAction) save:					(id) sender
{
    switch ([self.seriousnessIndex intValue])
    {
        case 0:
            self.seriousness =@"Minor";
            break;
        case 1:
            self.seriousness = @"Major";
            break;
        case 2:
            self.seriousness = @"Serious";
            break;
    }
    if (self.isEditMode)
    {
        self.sideEffects.SideEffect = self.selectedSideEffectLabel;
        self.sideEffects.SideEffectDate = self.effectsDate;
        self.sideEffects.seriousness = self.seriousness;
        self.sideEffects.UID = [Utilities GUID];
    }
    else
    {
        SideEffects *newEffects = [NSEntityDescription insertNewObjectForEntityForName:@"SideEffects"
                                                                inManagedObjectContext:self.context];
        newEffects.UID = [Utilities GUID];
        newEffects.SideEffect = self.selectedSideEffectLabel;
        newEffects.SideEffectDate = self.effectsDate;
        newEffects.Name = self.currentMeds;
        newEffects.seriousness = self.seriousness;
    }
    if (nil != self.context)
    {
        NSError *error = nil;
        if (![self.context save:&error])
        {
#ifdef APPDEBUG
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", nil)
                                        message:NSLocalizedString(@"Save error message", nil)
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles: nil]
             show];
        }
    }
    [self postNotification];
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) cancel:				(id) sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)postNotification
{
    NSNotification* refreshNotification =
    [NSNotification notificationWithName:@"RefetchAllDatabaseData"
                                  object:self
                                userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];

    NSNotification* animateNotification = [NSNotification
                                           notificationWithName:@"startAnimation"
                                           object:self
                                           userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:animateNotification];
}



- (IBAction)seriousnessChanged:(id)sender
{
    self.seriousnessIndex = [NSNumber numberWithInt:self.seriousnessControl.selectedSegmentIndex];    
}


- (void)changeDate
{
	NSString *title =  @"\n\n\n\n\n\n\n\n\n\n\n\n" ;
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Set", nil), nil];
	[actionSheet showInView:self.view];
	
	
	UIDatePicker *datePicker = [[UIDatePicker alloc] init];
	datePicker.tag = 101;
	datePicker.datePickerMode = UIDatePickerModeDate;
	[actionSheet addSubview:datePicker];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	UIDatePicker *datePicker = (UIDatePicker *)[actionSheet viewWithTag:101];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"dd MMM YY";
	
	NSString *timestamp = [formatter stringFromDate:datePicker.date];
    self.setDateCell.value.text = timestamp;
	self.effectsDate = datePicker.date;
}

- (IBAction) showAlertView:			(id) sender
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
        [self removeSQLEntry];
    }
}


- (void)removeSQLEntry
{
    [self.context deleteObject:self.sideEffects];
    NSError *error = nil;
    if (![self.context save:&error])
    {
#ifdef APPDEBUG
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", nil)
                                    message:NSLocalizedString(@"Save error message", nil)
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles: nil]
         show];
    }
    [self postNotification];
	[self dismissModalViewControllerAnimated:YES];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (0 == indexPath.section)
    {
        return 60;
    }
    else
    {
        return 48;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (1 == section)
    {
        return 40;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (2 == section)
    {
        return 40;
    }
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = nil;
    if (1 == section && nil != self.seriousnessControl)
    {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 36)];
        [headerView addSubview:self.seriousnessControl];
    }
    else
    {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    }
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = nil;
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    if (2 == section)
    {
        if (self.isEditMode)
        {
            footerView.frame = CGRectMake(0, 0, tableView.bounds.size.width, 50);
            CGRect deleteFrame = CGRectMake(10, 10, tableView.bounds.size.width - 20 , 37);
            GradientButton *deleteButton = [[GradientButton alloc] initWithFrame:deleteFrame colour:Red title:NSLocalizedString(@"Delete", @"Delete")];
            [deleteButton addTarget:self action:@selector(showAlertView:) forControlEvents:UIControlEventTouchUpInside];
            [footerView addSubview:deleteButton];
        }
    }
    
    return footerView;
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"dd MMM YY";
        
        NSString *identifier = @"SetDateCell";
        SetDateCell *dateCell = (SetDateCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == dateCell)
        {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"SetDateCell"
                                                                owner:self
                                                              options:nil];
            for (id currentObject in cellObjects)
            {
                if ([currentObject isKindOfClass:[SetDateCell class]])
                {
                    dateCell = (SetDateCell *)currentObject;
                    break;
                }
            }
        }
        dateCell.value.text = [formatter stringFromDate:self.effectsDate];
        dateCell.tag = 1;
        dateCell.labelImageView.image = [UIImage imageNamed:@"appointments.png"];
        dateCell.title.textColor = TEXTCOLOUR;
        self.setDateCell = dateCell;
        return dateCell;
    }
    else if (1 == indexPath.section)
    {
        NSString *identifier = @"ClinicAddressCell";
        ClinicAddressCell *cell = (ClinicAddressCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == cell)
        {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"ClinicAddressCell"
                                                                owner:self
                                                              options:nil];
            for (id currentObject in cellObjects)
            {
                if ([currentObject isKindOfClass:[ClinicAddressCell class]])
                {
                    cell = (ClinicAddressCell *)currentObject;
                    break;
                }
            }
            [cell setDelegate:self];
        }
        cell.title.text = NSLocalizedString(@"SideEffect", nil);
        if (self.isEditMode && ![self.sideEffects.SideEffect isEqualToString:@""])
        {
            cell.valueField.text = self.sideEffects.SideEffect;
            cell.valueField.textColor = [UIColor blackColor];
        }
        else
        {
            cell.valueField.text = NSLocalizedString(@"Enter Name", nil);
            cell.valueField.textColor = [UIColor lightGrayColor];
        }
        self.selectedEffectCell = cell;
        return cell;
    }
    else
    {
        NSString *identifier = @"UITableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:identifier];
        }
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        CGRect frame = CGRectMake(CGRectGetMinX(cell.bounds)+20.0, CGRectGetMinY(cell.bounds)+12.0, 180.0, 22.0);
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.textColor = TEXTCOLOUR;
        label.textAlignment = UITextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:15.0];
        label.text = NSLocalizedString(@"Select From List", nil);
        [cell addSubview:label];
        return cell;
    }
    return nil;
}


#pragma mark - Table view delegate
- (void) deselect: (id) sender
{
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        [self changeDate];
    }
    else if (2 == indexPath.section)
    {
        EffectsListController *listController = [[EffectsListController alloc] initWithNibName:@"EffectsListController" bundle:nil];
        listController.selectorDelegate = self;
        [self.navigationController pushViewController:listController animated:YES];        
    }
}

#pragma mark - Effects Selector method
- (void)selectedEffectFromList:(NSString *)effect
{
    self.selectedSideEffectLabel = effect;
    self.selectedEffectCell.valueField.text = effect;
    self.selectedEffectCell.valueField.textColor = [UIColor blackColor];
}

#pragma mark - ClinicAddress protocol implementations

- (void)setValueString:(NSString *)valueString withTag:(int)tag
{
    self.selectedSideEffectLabel = valueString;
}

- (void)setUnitString:(NSString *)unitString
{
}

@end
