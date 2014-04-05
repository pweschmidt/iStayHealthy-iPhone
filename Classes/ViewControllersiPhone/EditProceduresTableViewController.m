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
@property (nonatomic, strong) NSMutableDictionary *valueMap;
@end

@implementation EditProceduresTableViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self populateValues];
	if (self.isEditMode)
	{
		self.navigationItem.title = NSLocalizedString(@"Edit Illness", nil);
	}
	else
	{
		self.navigationItem.title = NSLocalizedString(@"New Illness", nil);
	}
}

- (void)populateValues
{
	self.valueMap = [NSMutableDictionary dictionary];
	self.editMenu = @[kName,
	                  kIllness,
	                  kCausedBy,
	                  kNotes];
	self.titleStrings = [NSMutableArray arrayWithCapacity:self.editMenu.count];
	if (self.isEditMode && nil != self.managedObject)
	{
		Procedures *procedures = (Procedures *)self.managedObject;
		[[[procedures entity] attributesByName] enumerateKeysAndObjectsUsingBlock: ^(NSString *attribute, id obj, BOOL *stop) {
		    id value = [procedures valueForKey:attribute];
		    if (nil != value)
		    {
		        if ([value isKindOfClass:[NSDate class]])
		        {
		            if ([attribute isEqualToString:kDate])
		            {
		                self.date = (NSDate *)value;
					}
				}
		        else if ([value isKindOfClass:[NSString class]])
		        {
		            if (![(NSString *)value isEqualToString : @""])
		            {
		                [self.valueMap setObject:value forKey:attribute];
					}
				}
			}
		}];
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
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
	[self.valueMap enumerateKeysAndObjectsUsingBlock: ^(NSString *attribute, NSString *value, BOOL *stop) {
	    [procedures addValueString:value type:attribute];
	}];
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

	id cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (0 == indexPath.section)
	{
		if (nil == cell)
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		}
		if (0 == indexPath.row)
		{
			[self configureDateCell:cell indexPath:indexPath dateType:DateOnly];
		}
		return cell;
	}
	else
	{
		if (nil == cell)
		{
			cell = [[PWESCustomTextfieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		}
		NSString *resultsString = [self.editMenu objectAtIndex:indexPath.row];
		NSString *text = NSLocalizedString(resultsString, nil);
		[self configureTableCell:cell title:text indexPath:indexPath hasNumericalInput:NO];
		return cell;
	}
}

- (void)configureTableCell:(PWESCustomTextfieldCell *)cell title:(NSString *)title indexPath:(NSIndexPath *)indexPath hasNumericalInput:(BOOL)hasNumericalInput
{
	[super configureTableCell:cell title:title indexPath:indexPath hasNumericalInput:hasNumericalInput];
	NSNumber *taggedViewNumber = [self tagNumberForIndex:indexPath.row segment:0];
	NSString *key = [self.editMenu objectAtIndex:indexPath.row];
	NSString *value = [self.valueMap objectForKey:key];
	if (nil != value)
	{
		UITextField *textField = [self customTextFieldForTagNumber:taggedViewNumber];
		if (nil != textField)
		{
			textField.text = value;
			textField.textColor = [UIColor blackColor];
		}
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[super textFieldDidEndEditing:textField];
	NSInteger tag = textField.tag - 1;
	if (0 <= tag && tag < self.editMenu.count)
	{
		NSString *key = [self.editMenu objectAtIndex:tag];
		[self.valueMap setObject:textField.text forKey:key];
	}
}

@end
