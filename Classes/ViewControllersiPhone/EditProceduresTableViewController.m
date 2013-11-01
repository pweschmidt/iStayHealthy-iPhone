//
//  EditProceduresTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/09/2013.
//
//

#import "EditProceduresTableViewController.h"
#import "Constants.h"
#import "CoreDataManager.h"
#import "Procedures+Handling.h"
#import "Utilities.h"
#import "UILabel+Standard.h"

@interface EditProceduresTableViewController ()
@property (nonatomic, strong) NSArray *editMenu;
@property (nonatomic, strong) NSMutableArray *titleStrings;
@end

@implementation EditProceduresTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.isEditMode)
    {
        self.navigationItem.title = NSLocalizedString(@"Edit Illness", nil);
    }
    else
    {
        self.navigationItem.title = NSLocalizedString(@"New Illness", nil);
    }
    self.editMenu = @[kName,
                      kIllness,
                      kCausedBy,
                      kNotes];
    self.titleStrings = [NSMutableArray arrayWithCapacity:self.editMenu.count];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setDefaultValues
{
    if (!self.isEditMode)
    {
        return;
    }
    Procedures *procedures = (Procedures *)self.managedObject;
    int index = 0;
    for (NSNumber *key  in self.textViews.allKeys)
    {
        id viewObj = [self.textViews objectForKey:key];
        if (nil != viewObj && [viewObj isKindOfClass:[UITextField class]] &&
            index < self.editMenu.count)
        {
            UITextField *textField = (UITextField *)viewObj;
            NSString *type = [self.editMenu objectAtIndex:index];
            textField.text = [procedures valueStringForType:type];
            if ([textField.text isEqualToString:NSLocalizedString(@"Enter Value", nil)])
            {
                textField.textColor = [UIColor lightGrayColor];
            }
        }
        ++index;
    }
    
}

- (void)save:(id)sender
{
    Procedures *procedures = nil;
    if (self.isEditMode)
    {
        procedures = (Procedures *)self.managedObject;
    }
    else
    {
        procedures = [[CoreDataManager sharedInstance] managedObjectForEntityName:kProcedures];
    }
    procedures.UID = [Utilities GUID];
    procedures.Date = self.date;
    int index = 0;
    for (NSNumber *number in self.textViews.allKeys)
    {
        id viewObj = [self.textViews objectForKey:number];
        if (nil != viewObj && [viewObj isKindOfClass:[UITextField class]] &&
            index < self.editMenu.count)
        {
            UITextField *textField = (UITextField *)viewObj;
            NSString *valueString = textField.text;
            NSString *type = [self.editMenu objectAtIndex:index];
            [procedures addValueString:valueString type:type];
        }
        ++index;
    }
    NSError *error = nil;
    [[CoreDataManager sharedInstance] saveContext:&error];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger resultsCount = self.editMenu.count;
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
            identifier = [NSString stringWithFormat:@"ProceduresCell"];
        }
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    if (0 == indexPath.row)
    {
        [self configureDateCell:cell indexPath:indexPath dateType:DateOnly];
    }
    else
    {
        if ([self hasInlineDatePicker])
        {
//            [self configureDatePickerCell:cell indexPath:indexPath];
        }
        else
        {
            NSUInteger titleIndex = (nil == self.datePickerIndexPath) ? indexPath.row - 1 : indexPath.row - 2;
            NSString *resultsString = [self.editMenu objectAtIndex:titleIndex];
            NSString *text = NSLocalizedString(resultsString, nil);
            [self configureTableCell:cell title:text indexPath:indexPath hasNumericalInput:YES];
        }
    }
    return cell;
}


@end
