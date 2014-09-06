//
//  EditResultsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 13/08/2013.
//
//

#import "EditResultsTableViewController.h"
#import "Constants.h"
#import "CoreDataManager.h"
#import "Results+Handling.h"
#import "Utilities.h"
#import "PWESBloodPressureCell.h"

@interface EditResultsTableViewController ()
{
	CGRect labelFrame;
	CGRect separatorFrame;
	CGRect textViewFrame;
}
@property (nonatomic, strong) NSDictionary *menus;
// @property (nonatomic, strong) NSArray *defaultValues;
@property (nonatomic, strong) NSArray *editResultsMenu;
@property (nonatomic, strong) NSMutableArray *titleStrings;
@property (nonatomic, strong) UISwitch *undetectableSwitch;
@property (nonatomic, strong) NSMutableDictionary *segmentMap;
@property (nonatomic, strong) NSMutableDictionary *valueMap;
@property (nonatomic, strong) UISegmentedControl *resultsSegmentControl;
@property (nonatomic, assign) BOOL bloodPressureHasChanged;
@end

@implementation EditResultsTableViewController

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
	self.bloodPressureHasChanged = NO;
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
	labelFrame = CGRectMake(20, 0, 115, 44);
	separatorFrame = CGRectMake(117, 4, 2, 40);
	textViewFrame = CGRectMake(120, 0, 150, 44);
	self.segmentMap = [NSMutableDictionary dictionary];

	if (self.isEditMode)
	{
		self.navigationItem.title = NSLocalizedString(@"Edit Result", nil);
	}
	else
	{
		self.navigationItem.title = NSLocalizedString(@"New Result", nil);
	}


	NSArray *menuTitles = @[NSLocalizedString(@"HIV", nil),
	                        NSLocalizedString(@"Bloods", nil),
	                        NSLocalizedString(@"Cells", nil),
	                        NSLocalizedString(@"Other", nil),
	                        NSLocalizedString(@"Liver", nil)];

	self.resultsSegmentControl = [[UISegmentedControl alloc] initWithItems:menuTitles];
	CGFloat width = self.tableView.bounds.size.width;
	if (320 < width)
	{
		width = 320;
	}
	CGFloat segmentWidth = width - 2 * 20;
	self.resultsSegmentControl.frame = CGRectMake(20, 3, segmentWidth, 30);
	self.resultsSegmentControl.selectedSegmentIndex = 0;
	[self.resultsSegmentControl addTarget:self action:@selector(indexDidChangeForSegment) forControlEvents:UIControlEventValueChanged];

	[self prepareMenus];

//	self.defaultValues = @[@"400-1500",
//	                       @"20.0 - 50.0",
//	                       @"10 - 10000000",
//	                       @"4.0 - 7.0",
//	                       @"3.0 - 6.0",
//	                       @"1.0 - 2.2"
//	                       @"2.0 - 3.4",
//	                       @"1.8 - 2.7",
//	                       @"3.5 - 11",
//	                       @"11.5 - 14.5",
//	                       @"150 - 450",
//	                       @"Enter your weight",
//	                       @"25",
//	                       @"120/80",
//	                       @"0.0 - 10.0"];

	self.titleStrings = [NSMutableArray arrayWithCapacity:self.editResultsMenu.count];
	self.undetectableSwitch = [[UISwitch alloc] init];
	[self.undetectableSwitch addTarget:self action:@selector(switchUndetectable:) forControlEvents:UIControlEventValueChanged];
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
	self.menuDelegate = nil;
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
	[self popController];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
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
		return self.editResultsMenu.count;
	}
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
		BOOL isBloodPressure = [self isBloodPressureForIndexPath:indexPath];
		NSString *resultsString = [self.editResultsMenu objectAtIndex:indexPath.row];
		NSString *text = NSLocalizedString(resultsString, nil);
		if (nil == cell)
		{
			if (isBloodPressure)
			{
				cell = [[PWESBloodPressureCell alloc] initWithStyle:UITableViewCellStyleDefault
				                                    reuseIdentifier:identifier];
			}
			else
			{
				cell = [[PWESCustomTextfieldCell alloc] initWithStyle:UITableViewCellStyleDefault
				                                      reuseIdentifier:identifier];
			}
		}

		if (isBloodPressure)
		{
			PWESBloodPressureCell *bpCell = (PWESBloodPressureCell *)cell;
			[self configureBloodPressureCell:bpCell title:text indexPath:indexPath];
		}
		else
		{
			PWESCustomTextfieldCell *customCell = (PWESCustomTextfieldCell *)cell;
			[self configureTableCell:customCell title:text indexPath:indexPath hasNumericalInput:YES];
		}
		return cell;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if (1 == section)
	{
		return 40;
	}
	return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	if (0 == section)
	{
		return 10;
	}
	return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *headerView = nil;

	if (1 == section)
	{
		headerView = [[UIView alloc]
		              initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 36)];
		[headerView addSubview:self.resultsSegmentControl];
	}
	else
	{
		headerView = [[UIView alloc]
		              initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
	}
	return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	UIView *footerView = [[UIView alloc]
	                      initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];

	if (1 == section && 0 == self.resultsSegmentControl.selectedSegmentIndex)
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

#pragma mark - textfield delegate overrides
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[self animateCellWithTextField:textField];
	if (nil == textField.text || [textField.text isEqualToString:@""])
	{
		return;
	}
	if ([textField.text isEqualToString:NSLocalizedString(@"Enter Value", nil)])
	{
		textField.text = @"";
	}
}

- (void)animateCellWithTextField:(UITextField *)textField
{
	textField.textColor = [UIColor blackColor];

	[UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations: ^{
	    [self.cellDictionary enumerateKeysAndObjectsUsingBlock: ^(id key, id cell, BOOL *stop) {
	        if ([cell isKindOfClass:[PWESCustomTextfieldCell class]])
	        {
	            PWESCustomTextfieldCell *customCell = (PWESCustomTextfieldCell *)cell;
	            if (textField != customCell.inputField)
	            {
	                [customCell shade];
				}
	            else
	            {
	                [customCell partialShade];
				}
			}
	        else if ([cell isKindOfClass:[PWESBloodPressureCell class]])
	        {
	            PWESBloodPressureCell *bpCell = (PWESBloodPressureCell *)cell;
	            if (textField != bpCell.systoleField && textField != bpCell.diastoleField)
	            {
	                [bpCell shade];
				}
	            else
	            {
	                [bpCell partialShade];
				}
			}
		}];
	} completion:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[super textFieldDidEndEditing:textField];
	if (nil == textField.text || [textField.text isEqualToString:@""])
	{
		return;
	}
	BOOL isFound = [self textFieldIsInDictionary:textField];
	if (!isFound)
	{
		return;
	}
	if (kSystoleFieldTag == textField.tag)
	{
		NSNumber *value = [NSNumber numberWithFloat:[textField.text floatValue]];
		[self.valueMap setObject:value forKey:kSystole];
		self.bloodPressureHasChanged = YES;
	}
	else if (kDiastoleFieldTag == textField.tag)
	{
		NSNumber *value = [NSNumber numberWithFloat:[textField.text floatValue]];
		[self.valueMap setObject:value forKey:kDiastole];
		self.bloodPressureHasChanged = YES;
	}
	else
	{
		NSNumber *foundTag = [NSNumber numberWithInteger:textField.tag];
		if (nil == foundTag)
		{
			return;
		}
		NSString *attribute = [self.segmentMap objectForKey:foundTag];
		if (nil != attribute)
		{
			NSNumber *value = [NSNumber numberWithFloat:[textField.text floatValue]];
			[self.valueMap setObject:value forKey:attribute];
		}
	}
}

- (void)createBloodPressureValuesFromString:(NSString *)bloodPressureString
                           bloodPressureTag:(NSInteger)bloodPressureTag
{
	if (nil == bloodPressureString || 0 == bloodPressureString.length || [bloodPressureString isEqualToString:@""])
	{
		return;
	}

	NSArray *components = [bloodPressureString componentsSeparatedByString:@"/"];
	if (2 != components.count)
	{
		components = [bloodPressureString componentsSeparatedByString:@" "];
	}
	if (2 == components.count)
	{
		NSString *systoleText = components[0];
		NSString *diastoleText = components[1];

		NSNumber *systole = [NSNumber numberWithFloat:[systoleText floatValue]];
		NSNumber *diastole = [NSNumber numberWithFloat:[diastoleText floatValue]];

		if (nil != systole)
		{
			[self.valueMap setObject:systole forKey:kSystole];
		}
		if (nil != diastole)
		{
			[self.valueMap setObject:diastole forKey:kDiastole];
		}
	}
}

- (NSString *)bloodPressureString
{
	NSNumber *systole = [self.valueMap objectForKey:kSystole];
	NSNumber *diastole = [self.valueMap objectForKey:kDiastole];

	NSMutableString *string = [NSMutableString string];

	if (nil != systole)
	{
		NSString *systoleText = [NSString stringWithFormat:@"%d", [systole intValue]];
		[string appendString:systoleText];
	}
	if (nil != diastole)
	{
		NSString *diastoleText = [NSString stringWithFormat:@"/%d", [diastole intValue]];
		[string appendString:diastoleText];
	}
	return [NSString stringWithString:string];
}

#pragma mark - private methods
- (void)configureTableCell:(PWESCustomTextfieldCell *)cell title:(NSString *)title indexPath:(NSIndexPath *)indexPath hasNumericalInput:(BOOL)hasNumericalInput
{
	[super configureTableCell:cell title:title indexPath:indexPath segmentIndex:self.resultsSegmentControl.selectedSegmentIndex hasNumericalInput:hasNumericalInput];
	NSNumber *tagNumber = [self tagNumberForIndex:indexPath.row
	                                      segment:self.resultsSegmentControl.selectedSegmentIndex];
	UITextField *textField = [self customTextFieldForTagNumber:tagNumber];
	if (nil == textField)
	{
		return;
	}
	NSString *attribute = [self.segmentMap objectForKey:tagNumber];
	if (nil != attribute && nil != textField)
	{
		if ([attribute isEqualToString:kBloodPressure])
		{
			NSString *bloodPressure = [self bloodPressureString];
			if (nil != bloodPressure)
			{
				textField.text = bloodPressure;
				textField.textColor = [UIColor blackColor];
				textField.enabled = YES;
			}
		}
		else
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
}

- (void)configureBloodPressureCell:(PWESBloodPressureCell *)cell
                             title:(NSString *)title
                         indexPath:(NSIndexPath *)indexPath
{
	NSNumber *taggedViewNumber = [self tagNumberForIndex:indexPath.row
	                                             segment:self.resultsSegmentControl.selectedSegmentIndex];

	cell.contentView.backgroundColor = [UIColor clearColor];
	PWESBloodPressureCell *retrievedCell = [self.cellDictionary objectForKey:taggedViewNumber];
	CGRect adjustedCellFrame = CGRectMake(0, 0, self.tableView.bounds.size.width, cell.contentView.frame.size.height);
	if (nil != retrievedCell)
	{
		[cell clear];
	}
	[cell createContentWithTitle:title textFieldDelegate:self contentFrame:adjustedCellFrame];



	NSString *attribute = [self.segmentMap objectForKey:taggedViewNumber];
	if (![attribute isEqualToString:kBloodPressure])
	{
		return;
	}
	NSNumber *systole = [self.valueMap objectForKey:kSystole];
	NSNumber *diastole = [self.valueMap objectForKey:kDiastole];
	if (nil != systole && 0 < [systole floatValue])
	{
		cell.systoleField.text = [NSString stringWithFormat:@"%d", [systole intValue]];
		cell.systoleField.enabled = YES;
		cell.systoleField.textColor = [UIColor blackColor];
	}
	else
	{
		cell.systoleField.text = @"120";
		cell.systoleField.enabled = YES;
		cell.systoleField.textColor = [UIColor lightGrayColor];
	}
	if (nil != diastole && 0 < [diastole floatValue])
	{
		cell.diastoleField.text = [NSString stringWithFormat:@"%d", [diastole intValue]];
		cell.diastoleField.enabled = YES;
		cell.diastoleField.textColor = [UIColor blackColor];
	}
	else
	{
		cell.diastoleField.text = @"80";
		cell.diastoleField.enabled = YES;
		cell.diastoleField.textColor = [UIColor lightGrayColor];
	}
	[self.cellDictionary setObject:cell forKey:taggedViewNumber];
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
		NSInteger indexForRow = [self tagForIndex:indexPath];
		identifier = [NSString stringWithFormat:@"ResultsCell%ld", (long)indexForRow];
	}
	return identifier;
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

- (void)indexDidChangeForSegment
{
	self.editResultsMenu = nil;
	switch (self.resultsSegmentControl.selectedSegmentIndex)
	{
		case 0:
			self.editResultsMenu = [self.menus objectForKey:@"HIV"];
			break;

		case 1:
			self.editResultsMenu = [self.menus objectForKey:@"Bloods"];
			break;

		case 2:
			self.editResultsMenu = [self.menus objectForKey:@"Cells"];
			break;

		case 3:
			self.editResultsMenu = [self.menus objectForKey:@"Other"];
			break;

		case 4:
			self.editResultsMenu = [self.menus objectForKey:@"Liver"];
			break;
	}
	NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:1];
	[self.tableView beginUpdates];
	[self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView endUpdates];
}

- (void)prepareMenus
{
	NSArray *hivMenu = @[kCD4,
	                     kCD4Percent,
	                     kViralLoad];

	[self prepareSegmentMapForMenu:hivMenu segment:0];

	NSArray *bloodMenu = @[kGlucose,
	                       kTotalCholesterol,
	                       kTriglyceride,
	                       kHDL,
	                       kLDL,
	                       kCholesterolRatio];
	[self prepareSegmentMapForMenu:bloodMenu segment:1];

	NSArray *cellsMenu = @[kHemoglobulin,
	                       kWhiteBloodCells,
	                       kRedBloodCells,
	                       kPlatelet];
	[self prepareSegmentMapForMenu:cellsMenu segment:2];

	NSArray *otherMenu = @[kWeight,
	                       kBMI,
	                       kBloodPressure,
	                       kCardiacRiskFactor];

	[self prepareSegmentMapForMenu:otherMenu segment:3];



	NSArray *liverMenu = @[kLiverAlanineTransaminase,
	                       kLiverAspartateTransaminase,
	                       kLiverAlkalinePhosphatase,
	                       kLiverGammaGlutamylTranspeptidase];
	[self prepareSegmentMapForMenu:liverMenu segment:4];


	self.menus = @{ @"HIV" : hivMenu,
		            @"Bloods" : bloodMenu,
		            @"Cells" : cellsMenu,
		            @"Other" : otherMenu,
		            @"Liver" : liverMenu };

	self.editResultsMenu = hivMenu;
}

- (void)prepareSegmentMapForMenu:(NSArray *)menu segment:(NSUInteger)segment
{
	for (NSUInteger index = 0; index < menu.count; ++index)
	{
		NSNumber *tag = [self tagNumberForIndex:index segment:segment];
		NSString *value = [menu objectAtIndex:index];
		[self.segmentMap setObject:value forKey:tag];
	}
}

- (NSInteger)tagForIndex:(NSIndexPath *)indexPath
{
	return pow(10, self.resultsSegmentControl.selectedSegmentIndex) + indexPath.row;
}

- (BOOL)isBloodPressureForIndexPath:(NSIndexPath *)indexPath
{
	if (3 != self.resultsSegmentControl.selectedSegmentIndex)
	{
		return NO;
	}
	BOOL isBP = NO;
	NSArray *bloods = [self.menus objectForKey:@"Other"];
	if (nil == bloods)
	{
		return isBP;
	}
	NSUInteger foundIndex = [bloods indexOfObject:kBloodPressure];
	if (bloods.count > foundIndex && indexPath.row == foundIndex)
	{
		isBP = YES;
	}

	return isBP;
}

@end
