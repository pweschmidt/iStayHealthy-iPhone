//
//  EditResultsTableViewController_iPad.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/04/2014.
//
//

#import "EditResultsTableViewController_iPad.h"
#import "Constants.h"
#import "CoreDataManager.h"
#import "Results+Handling.h"
#import "Utilities.h"
#import "PWESCustomTextfieldCell.h"
#import "UIFont+Standard.h"

@interface EditResultsTableViewController_iPad ()
@property (nonatomic, strong) NSArray *resultSections;
@property (nonatomic, strong) NSArray *defaultValues;
@property (nonatomic, strong) NSArray *editResultsMenu;
@property (nonatomic, strong) NSArray *headers;
@property (nonatomic, strong) NSMutableArray *titleStrings;
@property (nonatomic, strong) UISwitch *undetectableSwitch;
@property (nonatomic, strong) NSMutableDictionary *segmentMap;
@property (nonatomic, strong) NSMutableDictionary *valueMap;
@end

@implementation EditResultsTableViewController_iPad
- (id)  initWithStyle:(UITableViewStyle)style
        managedObject:(NSManagedObject *)managedObject
    hasNumericalInput:(BOOL)hasNumericalInput
{
	self = [super initWithStyle:style managedObject:managedObject hasNumericalInput:hasNumericalInput];
	if (nil != self)
	{
		[self populateValueMap];
	}
	return self;
}

- (void)populateValueMap
{
	self.valueMap = [NSMutableDictionary dictionary];
	self.segmentMap = [NSMutableDictionary dictionary];
	if (!self.isEditMode)
	{
		return;
	}
	Results *results = (Results *)self.managedObject;
	NSDictionary *attributes = [[results entity] attributesByName];

	for (NSString *attribute in attributes.allKeys)
	{
		id value = [results valueForKey:attribute];
		if ([value isKindOfClass:[NSDate class]])
		{
			self.date = (NSDate *)value;
		}
		else if ([value isKindOfClass:[NSNumber class]])
		{
			NSNumber *valueAsNumber = (NSNumber *)value;
			if (0 < [valueAsNumber floatValue])
			{
				[self.valueMap setObject:value forKey:attribute];
			}
		}
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	if (self.isEditMode)
	{
		self.navigationItem.title = NSLocalizedString(@"Edit Result", nil);
	}
	else
	{
		self.navigationItem.title = NSLocalizedString(@"New Result", nil);
	}
	[self prepareMenus];


	NSArray *menuTitles = @[NSLocalizedString(@"Date", nil),
	                        NSLocalizedString(@"HIV", nil),
	                        NSLocalizedString(@"Bloods", nil),
	                        NSLocalizedString(@"Cells", nil),
	                        NSLocalizedString(@"Other", nil),
	                        NSLocalizedString(@"Liver", nil)];
	self.headers = menuTitles;
	self.undetectableSwitch = [[UISwitch alloc] init];
	[self.undetectableSwitch addTarget:self
	                            action:@selector(switchUndetectable:)
	                  forControlEvents:UIControlEventValueChanged];
	if (self.isEditMode)
	{
		NSNumber *vlValue = [self.valueMap objectForKey:kViralLoad];
		if (nil != vlValue && 1 >= [vlValue floatValue])
		{
			[self.undetectableSwitch setOn:YES];
		}
		else
		{
			[self.undetectableSwitch setOn:NO];
		}
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
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

	NSDictionary *attributes = [[results entity] attributesByName];
	for (NSString *attribute in attributes.allKeys)
	{
		if ([attribute isEqualToString:kUID])
		{
			results.UID = [Utilities GUID];
		}
		else if ([attribute isEqualToString:kResultsDate])
		{
			results.ResultsDate = self.date;
		}
		else
		{
			NSNumber *value = [self.valueMap objectForKey:attribute];
			if (nil != value && 0 < [value floatValue])
			{
				[results setValue:value forKey:attribute];
			}
			else
			{
				[results setValue:@(-1) forKey:attribute];
			}
		}
	}

	NSError *error = nil;
	[[CoreDataManager sharedInstance] saveContextAndWait:&error];
	[self.navigationController popViewControllerAnimated:YES];
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
	return self.headers.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (0 == section)
	{
		return ([self hasInlineDatePicker] ? 2 : 1);
	}
	else
	{
		NSArray *currentMenu = [self.resultSections objectAtIndex:section];
		return currentMenu.count;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	if (1 == section)
	{
		return 40;
	}
	return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 40)];
	headerView.backgroundColor = [UIColor clearColor];
	UILabel *headerLabel = [[UILabel alloc] initWithFrame:headerView.frame];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.textColor = TEXTCOLOUR;
	headerLabel.textAlignment = NSTextAlignmentCenter;
	headerLabel.text = [self.headers objectAtIndex:section];
	headerLabel.font = [UIFont fontWithType:Light size:large];
	[headerView addSubview:headerLabel];
	return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	UIView *footerView = [[UIView alloc]
	                      initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
	if (1 == section)
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *identifier = [self identifierForIndexPath:indexPath];
	if (0 == indexPath.section)
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
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
		PWESCustomTextfieldCell *customCell = [tableView dequeueReusableCellWithIdentifier:identifier];
		if (nil == customCell)
		{
			customCell = [[PWESCustomTextfieldCell alloc] initWithStyle:UITableViewCellStyleDefault
			                                            reuseIdentifier:identifier];
		}
		NSArray *currentMenu = [self.resultSections objectAtIndex:indexPath.section];
		NSString *resultsString = [currentMenu objectAtIndex:indexPath.row];
		NSString *text = NSLocalizedString(resultsString, nil);
		[self configureTableCell:customCell title:text indexPath:indexPath hasNumericalInput:YES];
		return customCell;
	}
}

#pragma mark - textfield delegate overrides
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[super textFieldDidEndEditing:textField];
	if (nil == textField.text || [textField.text isEqualToString:@""])
	{
		return;
	}
	NSNumber *value = [NSNumber numberWithFloat:[textField.text floatValue]];
	__block NSNumber *foundTag = nil;
	[self.cellDictionary enumerateKeysAndObjectsUsingBlock: ^(NSNumber *tag, PWESCustomTextfieldCell *cell, BOOL *stop) {
	    UITextField *field = cell.inputField;
	    if ([field isEqual:textField])
	    {
	        foundTag = [NSNumber numberWithInteger:textField.tag];
		}
	}];
	if (nil == foundTag)
	{
		return;
	}
	NSString *attribute = [self.segmentMap objectForKey:foundTag];
	if (nil != attribute)
	{
		[self.valueMap setObject:value forKey:attribute];
	}
}

#pragma mark - private methods
- (void)configureTableCell:(PWESCustomTextfieldCell *)cell
                     title:(NSString *)title
                 indexPath:(NSIndexPath *)indexPath
         hasNumericalInput:(BOOL)hasNumericalInput
{
	[super configureTableCell:cell
	                    title:title
	                indexPath:indexPath
	             segmentIndex:indexPath.section
	        hasNumericalInput:hasNumericalInput];
	NSNumber *tagNumber = [self tagNumberForIndex:indexPath.row
	                                      segment:indexPath.section];
	PWESCustomTextfieldCell *customCell = [self.cellDictionary objectForKey:tagNumber];
	UITextField *textField = customCell.inputField;
	if (nil == textField)
	{
		return;
	}
	NSString *attribute = [self.segmentMap objectForKey:tagNumber];
	if (nil != attribute && nil != textField)
	{
		NSNumber *value = [self.valueMap objectForKey:attribute];
		if (0 < [value floatValue])
		{
			if ([attribute isEqualToString:kViralLoad] && 1 >= [value floatValue])
			{
				textField.text = NSLocalizedString(@"undetectable", nil);
				textField.textColor = [UIColor blackColor];
				textField.enabled = NO;
			}
			else
			{
				textField.text = [NSString stringWithFormat:@"%9.2f", [value floatValue]];
				textField.textColor = [UIColor blackColor];
				textField.enabled = YES;
			}
		}
		else
		{
			textField.text = NSLocalizedString(@"Enter Value", nil);
			textField.textColor = [UIColor lightGrayColor];
			textField.enabled = YES;
		}
	}
}

- (void)prepareMenus
{
	NSArray *dateMenu = @[@"Date"];
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



	NSArray *liverMenu = @[kLiverAlanineTransaminase,
	                       kLiverAspartateTransaminase,
	                       kLiverAlkalinePhosphatase,
	                       kLiverAlbumin,
	                       kLiverAlanineTotalBilirubin,
	                       kLiverAlanineDirectBilirubin,
	                       kLiverGammaGlutamylTranspeptidase];

	self.resultSections = @[dateMenu,
	                        hivMenu,
	                        bloodMenu,
	                        cellsMenu,
	                        otherMenu,
	                        liverMenu];
	[self prepareTagMapForMenus];
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
		NSInteger tag = [self tagForIndex:indexPath];
		identifier = [NSString stringWithFormat:@"ResultsCell%ld", (long)tag];
	}
	return identifier;
}

- (void)prepareTagMapForMenus
{
	[self.resultSections enumerateObjectsUsingBlock: ^(NSArray *menu, NSUInteger section, BOOL *stop) {
	    [menu enumerateObjectsUsingBlock: ^(NSString *menuItem, NSUInteger row, BOOL *stop) {
	        NSNumber *tag = [self tagNumberForIndex:row segment:section];
	        [self.segmentMap setObject:menuItem forKey:tag];
		}];
	}];
}

- (NSInteger)tagForIndex:(NSIndexPath *)indexPath
{
	return pow(10, indexPath.section) + indexPath.row;
}

- (void)switchUndetectable:(id)sender
{
	NSNumber *foundTag = nil;
	for (NSNumber *tag in self.segmentMap.allKeys)
	{
		NSString *vl = [self.segmentMap objectForKey:tag];
		if ([vl isEqualToString:kViralLoad])
		{
			foundTag = tag;
			break;
		}
	}
	if (nil == foundTag)
	{
		return;
	}
	UITextField *textField = [self customTextFieldForTagNumber:foundTag];
	if (nil == textField)
	{
		return;
	}
	if (self.undetectableSwitch.isOn)
	{
		textField.text = NSLocalizedString(@"undetectable", nil);
		textField.textColor = [UIColor blackColor];
		textField.enabled = NO;
		[self.valueMap setObject:@(1) forKey:kViralLoad];
	}
	else
	{
		textField.text = @"";
		textField.textColor = [UIColor blackColor];
		textField.enabled = YES;
		[self.valueMap removeObjectForKey:kViralLoad];
	}
}

@end
