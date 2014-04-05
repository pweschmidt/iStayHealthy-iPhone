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

@interface EditResultsTableViewController_iPad ()
@property (nonatomic, strong) NSArray *resultSections;
//@property (nonatomic, strong) NSDictionary *menus;
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
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)save:(id)sender
{
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
//		cell.tag = [self tagForIndex:indexPath];
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
//	for (NSNumber *tag in self.textViews.allKeys)
//	{
//		UITextField *field = [self.textViews objectForKey:tag];
//		if ([field isEqual:textField])
//		{
//			foundTag = tag;
//		}
//	}
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
- (void)configureTableCell:(PWESCustomTextfieldCell *)cell title:(NSString *)title indexPath:(NSIndexPath *)indexPath hasNumericalInput:(BOOL)hasNumericalInput
{
	[super configureTableCell:cell title:title indexPath:indexPath segmentIndex:indexPath.section hasNumericalInput:hasNumericalInput];
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

@end
