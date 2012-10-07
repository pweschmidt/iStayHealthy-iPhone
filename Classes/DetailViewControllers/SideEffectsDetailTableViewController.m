//
//  SideEffectsDetailTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/08/2012.
//
//

#import "SideEffectsDetailTableViewController.h"
#import "iStayHealthyRecord.h"
#import "SideEffects.h"
#import "SetDateCell.h"
#import "GeneralSettings.h"
#import "ChartSettings.h"
#import "GradientButton.h"
#import "Utilities.h"
#import "Medication.h"
#import <QuartzCore/QuartzCore.h>

@interface SideEffectsDetailTableViewController ()
@property BOOL isEditMode;
@property (nonatomic, strong) NSMutableArray *sideEffectArray;
@property (nonatomic, strong) NSMutableArray *currentMedArray;
@property (nonatomic, strong) NSString *currentMeds;
@property (nonatomic, strong) UITableViewCell *selectedCell;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) NSNumber *seriousnessIndex;
@property (nonatomic, strong) NSString *selectedSideEffectLabel;
@property (nonatomic, strong) NSString *seriousness;
@end

@implementation SideEffectsDetailTableViewController
@synthesize effectsDate = _effectsDate;
@synthesize record = _record;
@synthesize sideEffects = _sideEffects;
@synthesize setDateCell = _setDateCell;
@synthesize isEditMode = _isEditMode;
@synthesize sideEffectArray = _sideEffectArray;
@synthesize seriousnessControl = _seriousnessControl;
@synthesize currentMedArray = _currentMedArray;
@synthesize selectedCell = _selectedCell;
@synthesize formatter = _formatter;
@synthesize seriousnessIndex = _seriousnessIndex;
@synthesize seriousness = _seriousness;
@synthesize selectedSideEffectLabel = _selectedSideEffectLabel;
@synthesize currentMeds = _currentMeds;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (id)initWithResults:(SideEffects *)effects
         masterRecord:(iStayHealthyRecord *)masterRecord
{
    self = [super initWithNibName:@"SideEffectsDetailTableViewController" bundle:nil];
    if (nil != self)
    {
        self.isEditMode = YES;
        self.sideEffects = effects;
        self.effectsDate = self.sideEffects.SideEffectDate;
        self.currentMeds = self.sideEffects.Name;
        self.record = masterRecord;
        self.selectedCell = nil;
        self.formatter = [[NSDateFormatter alloc] init];
        self.formatter.dateFormat = @"dd MMM YY";
        self.seriousness = self.sideEffects.seriousness;
        if (nil == self.seriousness)
        {
            self.seriousnessIndex = [NSNumber numberWithInt:0];
        }
        else
        {
            if ([self.seriousness isEqualToString:@"Minor"])
            {
                self.seriousnessIndex = [NSNumber numberWithInt:0];
            }
            else if ([self.seriousness isEqualToString:@"Major"])
            {
                self.seriousnessIndex = [NSNumber numberWithInt:1];
            }
            else
            {
                self.seriousnessIndex = [NSNumber numberWithInt:2];
            }            
        }
#ifdef APPDEBUG
        NSLog(@"Seriousness is %@",self.seriousness);
#endif
    }
    return self;
}

- (id)initWithRecord:(iStayHealthyRecord *)masterrecord medication:(NSArray *)medArray
{
    self = [super initWithNibName:@"SideEffectsDetailTableViewController" bundle:nil];
    if (nil != self)
    {
        self.isEditMode = NO;
        self.effectsDate = [NSDate date];
        self.record = masterrecord;
        self.currentMedArray = [NSMutableArray arrayWithArray:medArray];
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
    NSString *effectsList = [[NSBundle mainBundle] pathForResource:@"SideEffects" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:effectsList];
    NSArray *list = [dict valueForKey:@"SideEffectArray"];
    NSArray *sortedList = [list sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    self.sideEffectArray = [NSMutableArray arrayWithArray:sortedList];

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
    NSManagedObjectContext *context = nil;
    if (self.isEditMode)
    {
        context = [self.sideEffects managedObjectContext];
        self.sideEffects.SideEffect = self.selectedSideEffectLabel;
        self.sideEffects.SideEffectDate = self.effectsDate;
        self.sideEffects.seriousness = self.seriousness;
        self.sideEffects.UID = [Utilities GUID];
        self.record.UID = [Utilities GUID];
    }
    else
    {
        context = [self.record managedObjectContext];
        SideEffects *newEffects = [NSEntityDescription insertNewObjectForEntityForName:@"SideEffects" inManagedObjectContext:context];
        [self.record addSideeffectsObject:newEffects];
        self.record.UID = [Utilities GUID];
        newEffects.UID = [Utilities GUID];
        newEffects.SideEffect = self.selectedSideEffectLabel;
        newEffects.SideEffectDate = self.effectsDate;
        NSMutableString *effectedDrugs = [NSMutableString string];
        for (Medication *med in self.currentMedArray)
        {
            NSString *name = med.Name;
            [effectedDrugs appendFormat:@"%@ ",name];
        }
        newEffects.Name = effectedDrugs;
        newEffects.seriousness = self.seriousness;
    }
    if (nil != context)
    {
        NSError *error = nil;
        if (![context save:&error])
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
	[self dismissModalViewControllerAnimated:YES];
}
- (IBAction) cancel:				(id) sender
{
	[self dismissModalViewControllerAnimated:YES];
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
    [self.record removeSideeffectsObject:self.sideEffects];
    NSManagedObjectContext *context = self.sideEffects.managedObjectContext;
    [context deleteObject:self.sideEffects];
    NSError *error = nil;
    if (![context save:&error])
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
	[self dismissModalViewControllerAnimated:YES];    
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 1;
    }
    else
    {
        return self.sideEffectArray.count;
    }
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
    else
        return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = 10;
    if (1 == section)
    {
        height = 40;
    }
    return height;
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
    if (1 == section)
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
    else {
        NSString *identifier = [NSString stringWithFormat:@"Row%d",indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if(nil == cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.textLabel.textColor = TEXTCOLOUR;
        cell.textLabel.text = [self.sideEffectArray objectAtIndex:indexPath.row];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        if (self.isEditMode && [self.sideEffects.SideEffect isEqualToString:cell.textLabel.text])
        {
            self.selectedSideEffectLabel = self.sideEffects.SideEffect;
            self.selectedCell = cell;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        if (cell == self.selectedCell)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        
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
    else if (1 == indexPath.section)
    {
        if (nil != self.selectedCell)
        {
            self.selectedCell.accessoryType = UITableViewCellAccessoryNone;
            self.selectedCell = nil;
        }
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.selectedCell = cell;
        self.selectedSideEffectLabel = cell.textLabel.text;
        [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
        
    }
}

@end
