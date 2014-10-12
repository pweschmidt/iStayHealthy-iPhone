//
//  EditHIVMedsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/08/2013.
//
//

#import "EditHIVMedsTableViewController.h"
#import "UITableViewCell+Extras.h"
#import "NSDate+Extras.h"
#import "CoreDataManager.h"
#import "Medication+Handling.h"
#import "Utilities.h"

@interface EditHIVMedsTableViewController ()
@property (nonatomic, strong) NSMutableDictionary *stateDictionary;
@property (nonatomic, strong) NSMutableDictionary *medicationListings;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, assign) BOOL isInitialLoad;
@end

@implementation EditHIVMedsTableViewController


- (void)viewDidLoad
{
	[super viewDidLoad];
	self.stateDictionary = [NSMutableDictionary dictionary];
	self.medicationListings = [NSMutableDictionary dictionary];
	if (self.isEditMode)
	{
		self.navigationItem.title = NSLocalizedString(@"Edit HIV Drugs", nil);
	}
	else
	{
		self.navigationItem.title = NSLocalizedString(@"Add HIV Drugs", nil);
	}

	/**
	   in case we want to enable loading lists of meds dynamically in future
	 */
//	UIBarButtonItem *save = [[UIBarButtonItem alloc]
//	                         initWithBarButtonSystemItem:UIBarButtonSystemItemSave
//	                                              target:self action:@selector(save:)];
//	UIBarButtonItem *reload = [[UIBarButtonItem alloc]
//	                           initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadMedications:)];

//	self.navigationItem.rightBarButtonItems = @[save /*, reload */];
	[self loadDrugs];
}

- (void)save:(id)sender
{
	__block NSMutableArray *selectedMeds = [NSMutableArray array];
	NSArray *keys = self.stateDictionary.allKeys;
	[keys enumerateObjectsUsingBlock: ^(NSIndexPath *indexPath, NSUInteger index, BOOL *stop) {
	    BOOL isSelected = [[self.stateDictionary objectForKey:indexPath] boolValue];
	    if (isSelected)
	    {
	        NSArray *meds = [self medicationArrayForIndexPath:indexPath];
	        if (meds.count > indexPath.row)
	        {
	            [selectedMeds addObject:[meds objectAtIndex:indexPath.row]];
			}
		}
	}];

	if (0 == selectedMeds.count)
	{
		return;
	}
	[selectedMeds enumerateObjectsUsingBlock: ^(NSArray *medDescription, NSUInteger index, BOOL *stop) {
	    Medication *medication = [[CoreDataManager sharedInstance]
	                              managedObjectForEntityName:kMedication];
	    medication.UID = [Utilities GUID];
	    medication.StartDate = self.date;
	    medication.Drug = [medDescription objectAtIndex:0];
	    medication.Name = [medDescription objectAtIndex:1];
	    medication.MedicationForm = [medDescription objectAtIndex:2];
	}];

	NSError *error = nil;
	[[CoreDataManager sharedInstance] saveContextAndWait:&error];
	[self popController];
}

- (void)reloadMedications:(id)sender
{
}

- (void)loadDrugs
{
	NSString *combipath = [[NSBundle mainBundle] pathForResource:@"CombiMeds" ofType:@"plist"];
	NSArray *combi = [[NSArray alloc]initWithContentsOfFile:combipath];
	[self.medicationListings setObject:combi forKey:[NSNumber numberWithInteger:1]];

	NSString *entryPath = [[NSBundle mainBundle] pathForResource:@"EntryInhibitors" ofType:@"plist"];
	NSArray *entry = [[NSArray alloc]initWithContentsOfFile:entryPath];
	[self.medicationListings setObject:entry forKey:[NSNumber numberWithInteger:2]];

	NSString *integrasePath = [[NSBundle mainBundle] pathForResource:@"IntegraseInhibitors" ofType:@"plist"];
	NSArray *integrase = [[NSArray alloc]initWithContentsOfFile:integrasePath];
	[self.medicationListings setObject:integrase forKey:[NSNumber numberWithInteger:3]];

	NSString *nnrtiPath = [[NSBundle mainBundle] pathForResource:@"NNRTI" ofType:@"plist"];
	NSArray *nnrti = [[NSArray alloc]initWithContentsOfFile:nnrtiPath];
	[self.medicationListings setObject:nnrti forKey:[NSNumber numberWithInteger:4]];

	NSString *nrtiPath = [[NSBundle mainBundle] pathForResource:@"NRTI" ofType:@"plist"];
	NSArray *nrti = [[NSArray alloc]initWithContentsOfFile:nrtiPath];
	[self.medicationListings setObject:nrti forKey:[NSNumber numberWithInteger:5]];

	NSString *proteasePath = [[NSBundle mainBundle] pathForResource:@"ProteaseInhibitors" ofType:@"plist"];
	NSArray *protease = [[NSArray alloc]initWithContentsOfFile:proteasePath];
	[self.medicationListings setObject:protease forKey:[NSNumber numberWithInteger:6]];


	NSString *boosterPath = [[NSBundle mainBundle] pathForResource:@"Booster" ofType:@"plist"];
	NSArray *boosters = [[NSArray alloc] initWithContentsOfFile:boosterPath];
	[self.medicationListings setObject:boosters forKey:[NSNumber numberWithInteger:7]];


	NSString *generaPath = [[NSBundle mainBundle] pathForResource:@"GeneralInhibitors" ofType:@"plist"];
	NSArray *generals = [[NSArray alloc] initWithContentsOfFile:generaPath];
	[self.medicationListings setObject:generals forKey:[NSNumber numberWithInteger:8]];

	self.startDate = [NSDate date];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 9;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSUInteger rows = 1;
	if (0 == section)
	{
		if ([self hasInlineDatePicker])
		{
			rows = 2;
		}
	}
	else
	{
		NSArray *meds = [self.medicationListings objectForKey:[NSNumber numberWithInteger:section]];
		if (nil != meds)
		{
			rows = meds.count;
		}
	}
	return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *identifier = [self cellIdentifierForIndexPath:indexPath];

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];


	if (nil == cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
		                              reuseIdentifier:identifier];
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
		[self configureMedicationCell:cell indexPath:indexPath];
	}

	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *text = @"";
	switch (section)
	{
		case 1:
			text = NSLocalizedString(@"Combination Tablets", nil);
			break;

		case 2:
			text = NSLocalizedString(@"Fusion/Entry Inhibitors", nil);
			break;

		case 3:
			text = NSLocalizedString(@"Integrase Inhibitors", nil);
			break;

		case 4:
			text = NSLocalizedString(@"non-Nucleoside Reverse Transcriptase Inhibitors", nil);
			break;

		case 5:
			text = NSLocalizedString(@"Nucleos(t)ide Reverse Transcriptase Inhibitors", nil);
			break;

		case 6:
			text = NSLocalizedString(@"Protease Inhibitors", nil);
			break;

		case 7:
			text = NSLocalizedString(@"Boosters/Inteferon", nil);
			break;

		case 8:
			text = NSLocalizedString(@"Other Inhibitors", nil);
			break;
	}
	return text;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (0 == indexPath.section)
	{
		if ([self indexPathHasPicker:indexPath])
		{
			return kBaseDateCellRowHeight;
		}
		else
		{
			return 44.0;
		}
	}
	return 60.0;
}

- (void)deselect:(id)sender
{
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow]
	                              animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (0 == indexPath.section)
	{
		[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
	else
	{
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		BOOL keyValue = [[self.stateDictionary objectForKey:indexPath] boolValue];
		BOOL isChecked = !keyValue;
		NSNumber *checked = [NSNumber numberWithBool:isChecked];
		[self.stateDictionary setObject:checked forKey:indexPath];
		cell.accessoryType = isChecked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
		[self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
	}
}

#pragma mark - configuring the med cells
- (void)configureMedicationCell:(UITableViewCell *)cell
                      indexPath:(NSIndexPath *)indexPath
{
	NSArray *description = [self medDescriptionForIndexPath:indexPath];

	NSNumber *checked = [self.stateDictionary objectForKey:indexPath];
	if (!checked)
	{
		[self.stateDictionary setObject:(checked = [NSNumber numberWithBool:NO]) forKey:indexPath];
	}
	cell.accessoryType = checked.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

	cell.selectionStyle = UITableViewCellSelectionStyleGray;


	NSString *imageName = [description objectAtIndex:3];
	NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
#ifdef APPDEBUG
	NSLog(@"IMAGE NAME IS %@ - with path at %@", imageName, path);
#endif
	UIImageView *imageView = [[UIImageView alloc]init];
	imageView.backgroundColor = [UIColor clearColor];
	imageView.frame = CGRectMake(20, 3, 55, 55);
	imageView.image = [UIImage imageWithContentsOfFile:path];

	UILabel *typeLabel = [[UILabel alloc] init];
	typeLabel.backgroundColor = [UIColor clearColor];
	typeLabel.frame = CGRectMake(83, 0, 200, 21);
	typeLabel.font = [UIFont italicSystemFontOfSize:12];
	typeLabel.textColor = [UIColor darkGrayColor];
	typeLabel.text = [description objectAtIndex:2];

	UILabel *nameLabel = [[UILabel alloc] init];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.frame = CGRectMake(83, 20, 200, 21);
	nameLabel.font = [UIFont systemFontOfSize:17];
	nameLabel.textColor = TEXTCOLOUR;
	nameLabel.text = [description objectAtIndex:1];

	UILabel *drugLabel = [[UILabel alloc] init];
	drugLabel.backgroundColor = [UIColor clearColor];
	drugLabel.frame = CGRectMake(83, 40, 200, 21);
	drugLabel.font = [UIFont italicSystemFontOfSize:12];
	drugLabel.textColor = [UIColor redColor];
	drugLabel.text = [description objectAtIndex:0];

	[cell.contentView addSubview:imageView];
	[cell.contentView addSubview:typeLabel];
	[cell.contentView addSubview:nameLabel];
	[cell.contentView addSubview:drugLabel];
}

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath
{
	if (0 == indexPath.section)
	{
		if (0 == indexPath.row)
		{
			return kBaseDateCellRowIdentifier;
		}
		else
		{
			return @"DatePickerCell";
		}
	}
	else
	{
		NSUInteger key = [self multiplierForIndexPath:indexPath];
		return [NSString stringWithFormat:@"MedicationCell %lu", (unsigned long)key];
	}
}

- (NSUInteger)multiplierForIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger multiplier = 1;
	NSInteger factor = 10;
	for (NSInteger i = 0; i < indexPath.section; i++)
	{
		multiplier *= factor;
	}
	multiplier += indexPath.row;
	return multiplier;
}

- (NSArray *)medDescriptionForIndexPath:(NSIndexPath *)indexPath
{
	if (0 == indexPath.section)
	{
		return nil;
	}
	NSArray *meds = [self medicationArrayForIndexPath:indexPath];
	NSArray *descriptionArray = (NSArray *)[meds objectAtIndex:indexPath.row];
	return descriptionArray;
}

- (NSArray *)medicationArrayForIndexPath:(NSIndexPath *)indexPath
{
	NSNumber *sectionKey = [NSNumber numberWithInteger:indexPath.section];
	id object = [self.medicationListings objectForKey:sectionKey];
	if (nil != object && [object isKindOfClass:[NSArray class]])
	{
		return (NSArray *)object;
	}
	return nil;
}

@end
