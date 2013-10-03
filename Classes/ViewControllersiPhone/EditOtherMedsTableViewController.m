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
@property (nonatomic, strong) NSArray * editMenu;
@property (nonatomic, strong) NSArray * unitArray;
@property (nonatomic, strong) NSMutableArray *titleStrings;
@property (nonatomic, strong) UISegmentedControl *unitControl;
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

- (void)deleteObject:(id)sender
{
    
}

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
    if ([self hasInlineDatePicker])
    {
        // we have a date picker, so allow for it in the number of rows in this section
        NSInteger numRows = self.editMenu.count + 1;
        return ++numRows;
    }
    return self.editMenu.count + 1;
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
            identifier = [NSString stringWithFormat:@"OtherMedCell%d",indexPath.row];
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
            NSString *text = [self.editMenu objectAtIndex:titleIndex];
            NSString *localisedText = NSLocalizedString([self.editMenu objectAtIndex:titleIndex], nil);
            BOOL hasNumericalInput = [text isEqualToString:kDose];
            [self configureTableCell:cell
                               title:localisedText
                           indexPath:indexPath
                   hasNumericalInput:hasNumericalInput];
        }
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 55;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] init];
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
    
}

@end
