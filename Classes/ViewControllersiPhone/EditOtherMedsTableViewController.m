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
@property (nonatomic, strong) NSArray *editMenu;
@property (nonatomic, strong) NSArray *unitArray;
@property (nonatomic, strong) NSMutableArray *titleStrings;
@property (nonatomic, strong) UISegmentedControl *unitControl;
@property (nonatomic, strong) NSMutableDictionary *valueMap;
- (void)changeUnit:(id)sender;
@end

@implementation EditOtherMedsTableViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self populateValues];
	if (self.isEditMode)
	{
		self.navigationItem.title = NSLocalizedString(@"Edit Other Medication", nil);
	}
	else
	{
		self.navigationItem.title = NSLocalizedString(@"New Other Medication", nil);
	}
}

- (void)populateValues
{
	self.valueMap = [NSMutableDictionary dictionary];
	self.editMenu = @[kName, kDose];
	self.titleStrings = [NSMutableArray arrayWithCapacity:self.editMenu.count];
	self.unitArray = @[@"g", @"mg", @"ml", @"other"];
	self.unitControl = [[UISegmentedControl alloc] initWithItems:self.unitArray];
	self.unitControl.selectedSegmentIndex = 1;
	unitIndex = 1;
	[self.unitControl addTarget:self action:@selector(changeUnit:) forControlEvents:UIControlEventValueChanged];
	if (self.isEditMode && nil != self.managedObject)
	{
		OtherMedication *otherMed = (OtherMedication *)self.managedObject;
		[[[otherMed entity] attributesByName] enumerateKeysAndObjectsUsingBlock: ^(NSString *attribute, id obj, BOOL *stop) {
		    id value = [otherMed valueForKey:attribute];
		    if (nil != value && ![attribute isEqualToString:kUID])
		    {
		        if ([value isKindOfClass:[NSDate class]])
		        {
		            if ([attribute isEqualToString:kStartDate])
		            {
		                self.date = (NSDate *)value;
					}
				}
		        else if ([value isKindOfClass:[NSNumber class]])
		        {
		            NSNumber *nValue = (NSNumber *)value;
		            NSString *valueString = [NSString stringWithFormat:@"%9.2f", [nValue floatValue]];
		            [self.valueMap setObject:valueString forKey:kDose];
				}
		        else if ([value isKindOfClass:[NSString class]])
		        {
		            if (kUnit == attribute)
		            {
		                NSString *unit = (NSString *)value;
		                NSInteger index = [self.unitArray indexOfObject:unit];
		                if (NSNotFound == index)
		                {
		                    unit = [NSString stringWithFormat:@"[%@]", unit];
		                    index = [self.unitArray indexOfObject:unit];
						}
		                if (NSNotFound != index && 0 <= index && index < self.unitArray.count)
		                {
		                    self.unitControl.selectedSegmentIndex = index;
						}
					}
		            else
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
	[self.valueMap enumerateKeysAndObjectsUsingBlock: ^(NSString *attribute, NSString *value, BOOL *stop) {
	    [med addValueString:value type:attribute];
	}];
	NSError *error = nil;
	[[CoreDataManager sharedInstance] saveContext:&error];
	[self popController];
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
		identifier = [NSString stringWithFormat:@"OtherMedCell%ld", (long)indexPath.row];
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
		NSString *text = [self.editMenu objectAtIndex:indexPath.row];
		NSString *localisedText = NSLocalizedString([self.editMenu objectAtIndex:indexPath.row], nil);
		BOOL hasNumericalInput = [text isEqualToString:kDose];
		[self configureTableCell:cell
		                   title:localisedText
		               indexPath:indexPath
		       hasNumericalInput:hasNumericalInput];
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
	NSInteger tag = textField.tag - 1;
	if (0 <= tag && tag < self.editMenu.count)
	{
		NSString *key = [self.editMenu objectAtIndex:tag];
		[self.valueMap setObject:textField.text forKey:key];
	}
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
	                  initWithFrame:CGRectMake(20, 10, tableView.bounds.size.width - 40, 20)];
	label.backgroundColor = [UIColor clearColor];
	label.text = NSLocalizedString(@"Select Unit", nil);
	label.textColor = TEXTCOLOUR;
	label.textAlignment = NSTextAlignmentJustified;
	label.font = [UIFont systemFontOfSize:15];
	[footerView addSubview:label];
	self.unitControl.frame = CGRectMake(20, 35, tableView.bounds.size.width - 40, 25);
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
