//
//  EditContactsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 02/10/2013.
//
//

#import "EditContactsTableViewController.h"
#import "Constants.h"
#import "CoreDataManager.h"
#import "Contacts+Handling.h"
#import "Utilities.h"
#import "UILabel+Standard.h"

@interface EditContactsTableViewController ()
@property (nonatomic, strong) NSArray *editMenu;
@property (nonatomic, strong) NSMutableArray *titleStrings;
@end

@implementation EditContactsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.isEditMode)
    {
        self.navigationItem.title = NSLocalizedString(@"Edit Clinic", nil);
    }
    else
    {
        self.navigationItem.title = NSLocalizedString(@"New Clinic", nil);
    }
    self.editMenu = @[kClinicName,
                      kClinicID,
                      kClinicWebSite,
                      kClinicEmailAddress,
                      kClinicContactNumber,
                      kEmergencyContactNumber];
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
    Contacts *contacts = (Contacts *)self.managedObject;
    int index = 0;
    for (NSNumber *key  in self.textViews.allKeys)
    {
        id viewObj = [self.textViews objectForKey:key];
        if (nil != viewObj && [viewObj isKindOfClass:[UITextField class]] &&
            index < self.editMenu.count)
        {
            UITextField *textField = (UITextField *)viewObj;
            NSString *type = [self.editMenu objectAtIndex:index];
            textField.text = [contacts valueStringForType:type];
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
    Contacts *contact = nil;
    if (self.isEditMode)
    {
        contact = (Contacts *)self.managedObject;
    }
    else
    {
        contact = [[CoreDataManager sharedInstance] managedObjectForEntityName:kContacts];
    }
    contact.UID = [Utilities GUID];
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
            [contact addValueString:valueString type:type];
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
    return self.editMenu.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"ContactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSString *resultsString = [self.editMenu objectAtIndex:indexPath.row];
    NSString *text = NSLocalizedString(resultsString, nil);
    [self configureTableCell:cell title:text indexPath:indexPath hasNumericalInput:NO];
    return cell;
}
@end
