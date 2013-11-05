//
//  EditOtherMedsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/09/2013.
//
//

#import "EditOtherMedsTableViewController.h"
#import "Constants.h"
#import "CoreDataManager.h"
#import "OtherMedication+Handling.h"
#import "Utilities.h"

@interface EditOtherMedsTableViewController ()
{
    NSUInteger unitIndex;
}
@property (nonatomic, strong) NSArray * editMenu;
@property (nonatomic, strong) NSArray * unitArray;
@property (nonatomic, strong) NSMutableArray *titleStrings;
@property (nonatomic, strong) UISegmentedControl *unitControl;
- (void)changeUnit:(id)sender;
@end

@implementation EditOtherMedsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"New Other Medication", nil);
    /*
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                              target:self action:@selector(save:)];
     */
    self.editMenu = @[kName, kDose];
    self.titleStrings = [NSMutableArray arrayWithCapacity:self.editMenu.count];
    self.unitArray = @[@"g", @"mg", @"ml", @"other"];
    self.unitControl = [[UISegmentedControl alloc] initWithItems:self.unitArray];
    self.unitControl.selectedSegmentIndex = 1;
    unitIndex = 1;
    [self.unitControl addTarget:self action:@selector(changeUnit:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setDefaultValues
{
    if(!self.isEditMode)
    {
        return;
    }
}


- (void)save:(id)sender
{
    OtherMedication *med = nil;
    if (!self.isEditMode)
    {
        med = [[CoreDataManager sharedInstance] managedObjectForEntityName:kOtherMedication];
    }
    else
    {
        med = (OtherMedication *)self.managedObject;
    }
    med.UID = [Utilities GUID];
    med.StartDate = self.date;
    med.Unit = [self.unitArray objectAtIndex:unitIndex];
    int index = 0;
    for (NSNumber *number in self.textViews)
    {
        id viewObj = [self.textViews objectForKey:number];
        if (nil != viewObj && [viewObj isKindOfClass:[UITextField class]])
        {
            UITextField *textField = (UITextField *)viewObj;
            NSString *valueString = textField.text;
            [med addValueString:valueString type:[self.editMenu objectAtIndex:index]];
        }
        index++;
    }
    NSError *error = nil;
    [[CoreDataManager sharedInstance] saveContext:&error];
    [self.navigationController popViewControllerAnimated:YES];
}

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
        return self.editMenu.count;
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
        identifier = [NSString stringWithFormat:@"OtherMedCell%d", indexPath.row];
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
        if (0 == indexPath.row)
        {
            [self configureDateCell:cell indexPath:indexPath dateType:DateOnly];
        }
    }
    else
    {
        NSString *text = [self.editMenu objectAtIndex:indexPath.row];
        NSString *localisedText = NSLocalizedString([self.editMenu objectAtIndex:indexPath.row], nil);
        BOOL hasNumericalInput = [text isEqualToString:kDose];
        [self configureTableCell:cell
                           title:localisedText
                       indexPath:indexPath
               hasNumericalInput:hasNumericalInput];
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 10;
    }
    else
    {
        return 55;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] init];
    if (0 == section)
    {
        footerView.frame = CGRectMake(0, 0, tableView.frame.size.width, 40);
        footerView.backgroundColor = [UIColor clearColor];
        return footerView;
    }
    footerView.frame = CGRectMake(0, 0, tableView.frame.size.width, 40);
    UILabel *label = [[UILabel alloc]
                      initWithFrame:CGRectMake(20, 10, tableView.bounds.size.width-40, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.text = NSLocalizedString(@"Select Unit", nil);
    label.textColor = TEXTCOLOUR;
    label.textAlignment = NSTextAlignmentJustified;
    label.font = [UIFont systemFontOfSize:15];
    [footerView addSubview:label];
    self.unitControl.frame = CGRectMake(20, 35, tableView.bounds.size.width-40, 25);
    [footerView addSubview:self.unitControl];
    return footerView;
}

- (void)changeUnit:(id)sender
{
    if ([sender isKindOfClass:[UISegmentedControl class]])
    {
        UISegmentedControl *segmenter = (UISegmentedControl *)sender;
        unitIndex = segmenter.selectedSegmentIndex;
    }
}

@end
