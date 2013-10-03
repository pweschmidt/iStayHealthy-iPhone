//
//  EditResultsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 13/08/2013.
//
//

#import "EditResultsTableViewController.h"
#import "Constants.h"
#import "CoreDataManager.h"
#import "Results+Handling.h"
#import "Utilities.h"

@interface EditResultsTableViewController ()
{
    CGRect labelFrame;
    CGRect separatorFrame;
    CGRect textViewFrame;
}
@property (nonatomic, strong) NSArray *defaultValues;
@property (nonatomic, strong) NSArray *resultsMenu;
@property (nonatomic, strong) NSArray *editResultsMenu;
@property (nonatomic, strong) NSArray *editResultsUndetectableMenu;
@property (nonatomic, strong) NSMutableArray *titleStrings;
@property (nonatomic, strong) UISwitch *undetectableSwitch;
@property (nonatomic, strong) NSIndexPath *viralLoadIndexPath;
@end

@implementation EditResultsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    labelFrame = CGRectMake(20, 0, 115, 44);
    separatorFrame = CGRectMake(117, 4, 2, 40);
    textViewFrame = CGRectMake(120, 0, 150, 44);
    if (self.isEditMode)
    {
        self.navigationItem.title = NSLocalizedString(@"Edit Result", nil);
    }
    else
    {
        self.navigationItem.title = NSLocalizedString(@"New Result", nil);
    }
//	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
//                                             initWithBarButtonSystemItem:UIBarButtonSystemItemSave
//                                             target:self action:@selector(save:)];
    self.viralLoadIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    self.editResultsMenu = @[kCD4,
                             kCD4Percent,
                             kViralLoad,
                             kGlucose,
                             kTotalCholesterol,
                             kHDL,
                             kLDL,
                             kHemoglobulin,
                             kWhiteBloodCells,
                             kRedBloodCells,
                             kPlatelet,
                             kWeight,
                             kBloodPressure,
                             kCardiacRiskFactor];
    
    self.editResultsUndetectableMenu = @[kCD4,
                                         kCD4Percent,
                                         kGlucose,
                                         kTotalCholesterol,
                                         kHDL,
                                         kLDL,
                                         kHemoglobulin,
                                         kWhiteBloodCells,
                                         kRedBloodCells,
                                         kPlatelet,
                                         kWeight,
                                         kBloodPressure,
                                         kCardiacRiskFactor];
    
    self.defaultValues = @[@"400-1500",
                           @"20.0 - 50.0",
                           @"10 - 10000000",
                           @"4.0 - 7.0",
                           @"3.0 - 6.0",
                           @"1.0 - 2.2"
                           @"2.0 - 3.4",
                           @"1.8 - 2.7",
                           @"3.5 - 11",
                           @"11.5 - 14.5",
                           @"150 - 450",
                           @"Enter your weight",
                           @"120/80",
                           @"0.0 - 10.0"];
    
    self.resultsMenu = self.editResultsMenu;
    self.titleStrings = [NSMutableArray arrayWithCapacity:self.resultsMenu.count];
    self.undetectableSwitch = [[UISwitch alloc] init];
    [self.undetectableSwitch addTarget:self action:@selector(switchUndetectable:) forControlEvents:UIControlEventValueChanged];
    [self.undetectableSwitch setOn:NO];
    self.menuDelegate = nil;
}

- (void)setDefaultValues
{
    if (!self.isEditMode)
    {
        return;
    }
    Results *results = (Results *)self.managedObject;
    int index = 0;
    self.date = results.ResultsDate;
    for (NSNumber *key  in self.textViews.allKeys)
    {
        id viewObj = [self.textViews objectForKey:key];
        if (nil != viewObj && [viewObj isKindOfClass:[UITextField class]] &&
            index < self.resultsMenu.count)
        {
            UITextField *textField = (UITextField *)viewObj;
            NSString *type = [self.resultsMenu objectAtIndex:index];
            textField.text = [results valueStringForType:type];
            if ([textField.text isEqualToString:NSLocalizedString(@"Enter Value", nil)])
            {
                textField.textColor = [UIColor lightGrayColor];
            }
            if ([type isEqualToString:kViralLoad] && [textField.text isEqualToString:NSLocalizedString(@"undetectable", nil)]) {
                [self.undetectableSwitch setOn:YES];
            }
        }
        ++index;
    }
}

- (void)save:(id)sender
{
    Results *results = nil;
    if (!self.isEditMode)
    {
        results = [[CoreDataManager sharedInstance]
                   managedObjectForEntityName:kResults];
    }
    else
    {
        results = (Results *)self.managedObject;
    }
    if (nil == results)
    {
        return;
    }
    results.UID = [Utilities GUID];
    results.ResultsDate = self.date;
    int index = 0;
    for (NSNumber *number in self.textViews.allKeys)
    {
        id viewObj = [self.textViews objectForKey:number];
        if (nil != viewObj && [viewObj isKindOfClass:[UITextField class]] &&
            index < self.resultsMenu.count)
        {
            UITextField *textField = (UITextField *)viewObj;
            NSString *valueString = textField.text;
            NSString *type = [self.resultsMenu objectAtIndex:index];
            [results addValueString:valueString type:type];
        }
        ++index;
    }
    if (self.undetectableSwitch.isOn)
    {
        [results addValueString:@"0" type:kViralLoad];
    }
    NSError *error = nil;
    [[CoreDataManager sharedInstance] saveContextAndWait:&error];
    
    [self.navigationController popViewControllerAnimated:YES];
    if (nil != self.menuDelegate)
    {
        if ([self.menuDelegate respondsToSelector:@selector(moveToNavigationControllerWithName:)])
        {
            [self.menuDelegate moveToNavigationControllerWithName:kResultsController];
        }
    }
}

- (void)deleteObject:(id)sender
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([self indexPathHasPicker:indexPath] ? kBaseDateCellRowHeight : self.tableView.rowHeight);
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger resultsCount = self.resultsMenu.count;
    resultsCount++;
    if ([self hasInlineDatePicker])
    {
        // we have a date picker, so allow for it in the number of rows in this section
        NSInteger numRows = resultsCount;
        return ++numRows;
    }
    return resultsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = nil;
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
            identifier = [NSString stringWithFormat:@"ResultsCell"];
        }
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    if (0 == indexPath.row)
    {
        [self configureDateCell:cell indexPath:indexPath];
    }
    else
    {
        if ([self hasInlineDatePicker])
        {
            [self configureDatePickerCell:cell indexPath:indexPath];
        }
        else
        {
            NSUInteger titleIndex = (nil == self.datePickerIndexPath) ? indexPath.row - 1 : indexPath.row - 2;
            NSString *resultsString = [self.resultsMenu objectAtIndex:titleIndex];
            NSString *text = NSLocalizedString(resultsString, nil);
            [self configureTableCell:cell title:text indexPath:indexPath hasNumericalInput:YES];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, tableView.frame.size.width, 40);
    UILabel *label = [[UILabel alloc]
                      initWithFrame:CGRectMake(20, 10, 150, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.text = NSLocalizedString(@"Undetectable?", nil);
    label.textColor = TEXTCOLOUR;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:15];
    [headerView addSubview:label];
    self.undetectableSwitch.frame = CGRectMake(180, 2, 80, 36);
    [headerView addSubview:self.undetectableSwitch];
    return headerView;
}

- (void)switchUndetectable:(id)sender
{
    [self.tableView beginUpdates];
    {
        NSArray *indexPaths = @[self.viralLoadIndexPath];
        if (self.undetectableSwitch.isOn)
        {
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            self.resultsMenu = self.editResultsUndetectableMenu;
        }
        else
        {
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            self.resultsMenu = self.editResultsMenu;
        }
    }
    [self.tableView endUpdates];
}

@end
