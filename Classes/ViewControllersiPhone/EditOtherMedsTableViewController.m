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
@property (nonatomic, strong) NSMutableArray *titleStrings;
@end

@implementation EditOtherMedsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"New Other Medication", nil);
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                              target:self action:@selector(save:)];
    self.editMenu = @[kName, kDose];
    self.titleStrings = [NSMutableArray arrayWithCapacity:self.editMenu.count];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setDefaultValues
{
    
}


- (IBAction)save:(id)sender
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
    
    NSError *error = nil;
    [[CoreDataManager sharedInstance] saveContext:&error];
    [self.navigationController popViewControllerAnimated:YES];
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
            NSString *text = NSLocalizedString([self.editMenu objectAtIndex:titleIndex], nil);
            [self configureTableCell:cell title:text indexPath:indexPath];
        }
    }
    return cell;
}

@end
