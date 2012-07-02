//
//  SideEffectDetailViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 27/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SideEffectDetailViewController.h"
#import "GeneralSettings.h"
#import "iStayHealthyRecord.h"
#import "SideEffects.h"
#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>

@interface SideEffectDetailViewController ()
@property (nonatomic, strong) NSMutableArray *sideEffectArray;
@property (nonatomic, strong) UITableViewCell *selectedCell;
@property (nonatomic, strong) NSNumber *seriousnessIndex;
@property (nonatomic, strong) NSDate *effectDate;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) iStayHealthyRecord *masterRecord;
@property (nonatomic, strong) SideEffects *sideEffects;
@property BOOL isEditingExistingEffect;
@end

@implementation SideEffectDetailViewController
@synthesize sideEffectTableView = _sideEffectTableView;
@synthesize sideEffectArray = _sideEffectArray;
@synthesize seriousnessControl = _seriousnessControl;
@synthesize selectedCell = _selectedCell;
@synthesize seriousnessIndex = _seriousnessIndex;
@synthesize dateLabel = _dateLabel;
@synthesize dateButton = _dateButton;
@synthesize effectDate = _effectDate;
@synthesize formatter = _formatter;
@synthesize selectedSideEffectLabel = _selectedSideEffectLabel;
@synthesize isEditingExistingEffect = _isEditingExistingEffect;
@synthesize masterRecord = _masterRecord;
@synthesize sideEffects = _sideEffects;
@synthesize sideEffectDelegate = _sideEffectDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isEditingExistingEffect = NO;
    }
    return self;
}

- (id)initWithRecord:(iStayHealthyRecord *)record effectDelegate:(id)effectDelegate{
    return [self initWithRecord:record sideEffects:nil effectDelegate:effectDelegate];
}

- (id)initWithRecord:(iStayHealthyRecord *)record sideEffects:(SideEffects *)effects effectDelegate:(id)effectDelegate{
    self = [self initWithNibName:@"SideEffectDetailViewController" bundle:nil];
    if (self) {
        self.sideEffectDelegate = effectDelegate;
        self.masterRecord = record;
        self.sideEffects = effects;
        self.effectDate = [NSDate date];
        if (nil != effects) {
            self.isEditingExistingEffect = YES;
            self.effectDate = self.sideEffects.SideEffectDate;
        }
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *effectsList = [[NSBundle mainBundle] pathForResource:@"SideEffects" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:effectsList];
    NSArray *list = [dict valueForKey:@"SideEffectArray"];
    
    self.sideEffectArray = [NSMutableArray arrayWithArray:list];
    self.selectedSideEffectLabel.text = @"";
    self.sideEffectTableView.layer.cornerRadius = 20.0;
    self.sideEffectTableView.layer.frame = CGRectInset(self.sideEffectTableView.frame, 20.0, 20.0);
    self.sideEffectTableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.sideEffectTableView.layer.borderWidth = 1.0;
    self.sideEffectTableView.layer.masksToBounds = YES;
    self.seriousnessIndex = [NSNumber numberWithInt:0];
    self.seriousnessControl.selectedSegmentIndex = 0;
	self.formatter = [[NSDateFormatter alloc] init];
	self.formatter.dateFormat = @"dd MMM YY";
    
    self.effectDate = [NSDate date];
    self.dateLabel.textColor = TEXTCOLOUR;
    self.dateLabel.text = [self.formatter stringFromDate:self.effectDate];
    self.selectedCell = nil;
}

- (void)viewWillDisappear:(BOOL)animated{
    if (nil != self.selectedCell) {
        NSManagedObjectContext *context = [self.masterRecord managedObjectContext];
        NSError *error = nil;
        if (!self.isEditingExistingEffect && ![self.selectedSideEffectLabel.text isEqualToString:@""]) {
            SideEffects *newEffect = [NSEntityDescription insertNewObjectForEntityForName:@"SideEffects" inManagedObjectContext:context];
            [self.masterRecord addSideeffectsObject:newEffect];
            self.masterRecord.UID = [Utilities GUID];
            newEffect.SideEffectDate = self.effectDate;
            newEffect.SideEffect = self.selectedSideEffectLabel.text;
            if (![context save:&error]) {
#ifdef APPDEBUG
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
                abort();
            }
        }
    }
    if ([self.sideEffectDelegate respondsToSelector:@selector(updateSideEffectTable)]) {
        [self.sideEffectDelegate updateSideEffectTable];
    }
}


- (void)viewDidUnload
{
    self.selectedCell = nil;
    self.sideEffectArray = nil;
    self.seriousnessIndex = nil;
    self.effectDate = nil;
    self.formatter = nil;
    self.masterRecord = nil;
    self.sideEffects = nil;
    [super viewDidUnload];
}

- (IBAction)seriousnessChanged:(id)sender{
    self.seriousnessIndex = [NSNumber numberWithInt:self.seriousnessControl.selectedSegmentIndex];
}

- (IBAction)setDate:(id)sender{
    NSString *title = @"\n\n\n\n\n\n\n\n\n\n\n\n" ;	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Set",nil), nil];
	[actionSheet showInView:self.view];
	
	
	UIDatePicker *datePicker = [[UIDatePicker alloc] init];
	datePicker.tag = 101;
	datePicker.datePickerMode = UIDatePickerModeDate;
	[actionSheet addSubview:datePicker];    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) deselect: (id) sender
{
	[self.sideEffectTableView 
     deselectRowAtIndexPath:[self.sideEffectTableView indexPathForSelectedRow] 
     animated:YES];
}

#pragma mark Actionsheet Delegate methods
/**
 sets the label and resultsdate to the one selected
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	UIDatePicker *datePicker = (UIDatePicker *)[actionSheet viewWithTag:101];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"dd MMM YY";
	
	NSString *timestamp = [formatter stringFromDate:datePicker.date];
	self.dateLabel.text = timestamp;
	self.effectDate = datePicker.date;
}


#pragma mark Table Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sideEffectArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"Row%d",indexPath.row];    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(nil == cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.textColor = TEXTCOLOUR;
    cell.textLabel.text = [self.sideEffectArray objectAtIndex:indexPath.row];
    if ([cell.textLabel.text isEqualToString:[self.sideEffectArray lastObject]]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    if (cell == self.selectedCell) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

#pragma mark Table Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSLog(@"SideEffectDetailViewController::selected row %d",indexPath.row);

    if (indexPath.row == self.sideEffectArray.count - 1) {
        NSLog(@"SideEffectDetailViewController::selected row %d. Is last row",indexPath.row);
        [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
        return;
    }
    if (nil != self.selectedCell) {
        self.selectedCell.accessoryType = UITableViewCellAccessoryNone;
        self.selectedCell = nil;
    }
    UITableViewCell *cell = [self.sideEffectTableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.selectedCell = cell;
    self.selectedSideEffectLabel.text = cell.textLabel.text;
    [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
}

@end
