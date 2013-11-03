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
@property (nonatomic, strong) NSDictionary *menus;
@property (nonatomic, strong) NSArray *defaultValues;
@property (nonatomic, strong) NSArray *editResultsMenu;
@property (nonatomic, strong) NSMutableArray *titleStrings;
@property (nonatomic, strong) UISwitch *undetectableSwitch;
@property (nonatomic, strong) UISegmentedControl *resultsSegmentControl;
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
    
    NSArray *hivMenu = @[kCD4,
                         kCD4Percent,
                         kViralLoad];
    
    NSArray *bloodMenu = @[kGlucose,
                           kTotalCholesterol,
                           kTriglyceride,
                           kHDL,
                           kLDL,
                           kCholesterolRatio];
    NSArray *cellsMenu = @[kHemoglobulin,
                           kWhiteBloodCells,
                           kRedBloodCells,
                           kPlatelet];
    NSArray *otherMenu = @[kWeight,
                           kBMI,
                           kBloodPressure,
                           kCardiacRiskFactor];

    
    NSArray *menuTitles = @[NSLocalizedString(@"HIV Result", nil),
                            NSLocalizedString(@"Blood Result", nil),
                            NSLocalizedString(@"Cells", nil),
                            NSLocalizedString(@"Other Result", nil)];
    self.resultsSegmentControl = [[UISegmentedControl alloc] initWithItems:menuTitles];
    
    CGFloat width = self.tableView.bounds.size.width;
    CGFloat segmentWidth = width - 2 * 20;
    self.resultsSegmentControl.frame = CGRectMake(20, 3, segmentWidth, 30);
    self.resultsSegmentControl.tintColor = TINTCOLOUR;
    self.resultsSegmentControl.selectedSegmentIndex = 0;
    [self.resultsSegmentControl addTarget:self action:@selector(indexDidChangeForSegment) forControlEvents:UIControlEventValueChanged];
    
    self.menus = @{@"HIV" : hivMenu,
                   @"Bloods" : bloodMenu,
                   @"Cells" : cellsMenu,
                   @"Other" : otherMenu};
    
    self.editResultsMenu = hivMenu;
    
    
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
                           @"25",
                           @"120/80",
                           @"0.0 - 10.0"];
    
    self.titleStrings = [NSMutableArray arrayWithCapacity:self.editResultsMenu.count];
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
            index < self.editResultsMenu.count)
        {
            UITextField *textField = (UITextField *)viewObj;
            NSString *type = [self.editResultsMenu objectAtIndex:index];
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
            index < self.editResultsMenu.count)
        {
            UITextField *textField = (UITextField *)viewObj;
            NSString *valueString = textField.text;
            NSString *type = [self.editResultsMenu objectAtIndex:index];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        return ([self indexPathHasPicker:indexPath] ? kBaseDateCellRowHeight : self.tableView.rowHeight);
    }
    else
    {
        return self.tableView.rowHeight;
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return ([self hasInlineDatePicker] ? 2 : 1);
    }
    else
    {
        return self.editResultsMenu.count;
    }
}


- (NSString *)identifierForIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = nil;
    if (0 == indexPath.section)
    {
        identifier = [NSString stringWithFormat:kBaseDateCellRowIdentifier];
        if ([self hasInlineDatePicker])
        {
            identifier = [NSString stringWithFormat:@"DatePickerCell"];
        }
    }
    else
    {
        identifier = [NSString stringWithFormat:@"ResultsCell%d", indexPath.row];
    }
    return identifier;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [self identifierForIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    if (0 == indexPath.section)
    {
        [self configureDateCell:cell indexPath:indexPath dateType:DateOnly];
    }
    else
    {
        NSString *resultsString = [self.editResultsMenu objectAtIndex:indexPath.row];
        NSString *text = NSLocalizedString(resultsString, nil);
        [self configureTableCell:cell title:text indexPath:indexPath hasNumericalInput:YES];
    }
    return cell;
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
    if (0 == section)
    {
        return 10;
    }
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = nil;
    if (1 == section)
    {
        headerView = [[UIView alloc]
                      initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 36)];
        [headerView addSubview:self.resultsSegmentControl];
    }
    else
    {
        headerView = [[UIView alloc]
                      initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    }
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc]
                          initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    if (1 == section && 0 == self.resultsSegmentControl.selectedSegmentIndex)
    {
        footerView = [[UIView alloc]
                      initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 36)];
        UILabel *label = [[UILabel alloc]
                          initWithFrame:CGRectMake(20, 10, 150, 20)];
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"Undetectable?", nil);
        label.textColor = TEXTCOLOUR;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15];
        [footerView addSubview:label];
        self.undetectableSwitch.frame = CGRectMake(180, 2, 80, 36);
        [footerView addSubview:self.undetectableSwitch];
    }
    return footerView;
}


- (void)switchUndetectable:(id)sender
{
}

- (void)indexDidChangeForSegment
{
    self.editResultsMenu = nil;
    switch (self.resultsSegmentControl.selectedSegmentIndex)
    {
        case 0:
            self.editResultsMenu = [self.menus objectForKey:@"HIV"];
            break;
        case 1:
            self.editResultsMenu = [self.menus objectForKey:@"Bloods"];
            break;
        case 2:
            self.editResultsMenu = [self.menus objectForKey:@"Cells"];
            break;
        case 3:
            self.editResultsMenu = [self.menus objectForKey:@"Other"];
            break;
    }
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:1];
    [self.tableView beginUpdates];
    [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}


@end
