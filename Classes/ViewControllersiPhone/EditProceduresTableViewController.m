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
        identifier = [NSString stringWithFormat:@"ProceduresCell"];
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
        NSString *resultsString = [self.editMenu objectAtIndex:indexPath.row];
        NSString *text = NSLocalizedString(resultsString, nil);
        [self configureTableCell:cell title:text indexPath:indexPath hasNumericalInput:YES];
    }
    return cell;
}


@end
