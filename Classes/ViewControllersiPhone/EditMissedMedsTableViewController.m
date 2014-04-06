//
//  EditMissedMedsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/09/2013.
//
//

#import "EditMissedMedsTableViewController.h"
#import "Constants.h"
#import "CoreDataManager.h"
#import "MissedMedication+Handling.h"
#import "Medication+Handling.h"
#import "Utilities.h"
#import "UILabel+Standard.h"

@interface EditMissedMedsTableViewController ()
@property (nonatomic, strong) NSArray *editMenu;
@property (nonatomic, strong) NSArray *unitArray;
@property (nonatomic, strong) NSArray *currentMeds;
@property (nonatomic, strong) NSMutableArray *titleStrings;
@property (nonatomic, strong) NSIndexPath *selectedReasonPath;
@property (nonatomic, strong) NSMutableDictionary *selectedMedPaths;
@end

@implementation EditMissedMedsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
        currentMeds:(NSArray *)currentMeds
      managedObject:(NSManagedObject *)managedObject
{
	self = [super  initWithStyle:style
	               managedObject:managedObject
	           hasNumericalInput:NO];
	if (nil != self)
	{
		if (nil == currentMeds)
		{
			_currentMeds = [NSArray array];
		}
		else
		{
			_currentMeds = currentMeds;
		}
		[self populateValues];
	}
	return self;
}

- (void)populateValues
{
	self.editMenu = @[kMissedReasonForgotten,
	                  kMissedReasonNoMeds,
	                  kMissedReasonUnable,
	                  kMissedReasonUnwilling,
	                  kMissedReasonOther];
	self.selectedReasonPath = nil;
	self.selectedMedPaths = [NSMutableDictionary dictionary];
	NSUInteger medSection = 2;
	[self.currentMeds enumerateObjectsUsingBlock: ^(Medication *medication, NSUInteger index, BOOL *stop) {
	    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:medSection];
	    NSNumber *value = [NSNumber numberWithBool:NO];
	    [self.selectedMedPaths setObject:value forKey:indexPath];
	}];

	if (self.isEditMode)
	{
		MissedMedication *missedMed = (MissedMedication *)self.managedObject;
		NSString *reason = missedMed.missedReason;
		if (nil != reason)
		{
			NSUInteger foundIndex = [self.editMenu indexOfObject:reason];
			if (NSNotFound != foundIndex)
			{
				self.selectedReasonPath = [NSIndexPath indexPathForRow:foundIndex inSection:1];
			}
		}
		NSArray *components = [missedMed.Name componentsSeparatedByString:@","];
		[self.currentMeds enumerateObjectsUsingBlock: ^(Medication *medication, NSUInteger index, BOOL *stop) {
		    NSString *name = medication.Name;
		    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:medSection];
		    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@", name];
		    NSArray *filtered = [components filteredArrayUsingPredicate:predicate];
		    if (nil != filtered && 0 < filtered.count)
		    {
		        [self.selectedMedPaths setObject:[NSNumber numberWithBool:YES] forKey:indexPath];
			}
		}];
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.navigationItem.title = NSLocalizedString(@"New Missed Medication", nil);
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)save:(id)sender
{
	if (nil == self.selectedReasonPath)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Reason is missing", nil) message:NSLocalizedString(@"Please select a reason", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil];
		[alert show];
		return;
	}
	__block BOOL found = NO;
	[self.selectedMedPaths enumerateKeysAndObjectsUsingBlock: ^(NSIndexPath *key, NSNumber *obj, BOOL *stop) {
	    if ([obj boolValue])
	    {
	        found = YES;
		}
	}];
	if (!found)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Med is missing", nil) message:NSLocalizedString(@"Please select a medication", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil];
		[alert show];
		return;
	}


	MissedMedication *med = nil;
	if (self.isEditMode)
	{
		med = (MissedMedication *)self.managedObject;
	}
	else
	{
		med = [[CoreDataManager sharedInstance] managedObjectForEntityName:kMissedMedication];
	}
	med.UID = [Utilities GUID];
	med.MissedDate = self.date;
	if (nil != self.selectedReasonPath)
	{
		med.missedReason = [self.editMenu objectAtIndex:self.selectedReasonPath.row];
	}
	if (nil != self.selectedMedPaths)
	{
		__block NSMutableString *names = [NSMutableString string];
		[self.selectedMedPaths enumerateKeysAndObjectsUsingBlock: ^(NSIndexPath *key, NSNumber *checked, BOOL *stop) {
		    if ([checked boolValue])
		    {
		        if (0 < names.length)
		        {
		            [names appendString:@","];
				}
		        Medication *med = [self.currentMeds objectAtIndex:key.row];
		        [names appendString:med.Name];
			}
		}];
		if (0 < names.length)
		{
			med.Name = names;
		}
	}
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
	else if (1 == indexPath.section)
	{
		return self.tableView.rowHeight;
	}
	else
	{
		return 60;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (0 == section)
	{
		return ([self hasInlineDatePicker] ? 2 : 1);
	}
	else if (1 == section)
	{
		return self.editMenu.count;
	}
	else
	{
		return self.currentMeds.count;
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
	else if (1 == indexPath.section)
	{
		identifier = [NSString stringWithFormat:@"MissedReasonCell%d", indexPath.row];
	}
	else
	{
		identifier = [NSString stringWithFormat:@"CurrentMedCell%d", indexPath.row];
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
	else if (1 == indexPath.section)
	{
		NSString *localisedText = NSLocalizedString([self.editMenu objectAtIndex:indexPath.row], nil);
		[self configureCell:cell text:localisedText indexPath:indexPath];
	}
	else
	{
		Medication *current = (Medication *)[self.currentMeds objectAtIndex:indexPath.row];
		[self configureMedCell:cell med:current indexPath:indexPath];
	}
	return cell;
}

- (void)configureCell:(UITableViewCell *)cell
                 text:(NSString *)text
            indexPath:(NSIndexPath *)indexPath
{
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	UILabel *label = [UILabel standardLabel];
	label.frame = CGRectMake(20, 0, 200, self.tableView.rowHeight);
	label.text = text;
	if (nil != self.selectedReasonPath)
	{
		if (indexPath.row == self.selectedReasonPath.row && indexPath.section == self.selectedReasonPath.section)
		{
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
	}
	[cell.contentView addSubview:label];
}

- (void)configureMedCell:(UITableViewCell *)cell
                     med:(Medication *)med
               indexPath:(NSIndexPath *)indexPath
{
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	NSNumber *checked = [self.selectedMedPaths objectForKey:indexPath];
	if (nil == checked)
	{
	}
	else
	{
		if ([checked boolValue])
		{
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
	}

	UIImageView *imageView = [[UIImageView alloc] init];
	imageView.backgroundColor = [UIColor clearColor];
	imageView.frame = CGRectMake(20, 2, 55, 55);
	NSString *pathName = [Utilities imageNameFromMedName:med.Name];
	if (nil != pathName)
	{
		NSString *pillPath = [[NSBundle mainBundle]
		                      pathForResource:[pathName lowercaseString] ofType:@"png"];
		imageView.image = [UIImage imageWithContentsOfFile:pillPath];
	}

	UILabel *label = [UILabel standardLabel];
	label.text = med.Name;
	label.frame = CGRectMake(80, 0, 180, self.tableView.rowHeight);

	[cell.contentView addSubview:imageView];
	[cell.contentView addSubview:label];
}

- (void)deselect:(id)sender
{
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	if (1 == indexPath.section)
	{
		if (nil != self.selectedReasonPath)
		{
			UITableViewCell *checkedCell = [self.tableView cellForRowAtIndexPath:self.selectedReasonPath];
			checkedCell.accessoryType = UITableViewCellAccessoryNone;
		}
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		self.selectedReasonPath = indexPath;
		[self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
	}
	else if (2 == indexPath.section)
	{
		BOOL checkedValue = [[self.selectedMedPaths objectForKey:indexPath] boolValue];
		BOOL checkedUnchecked = !checkedValue;
		[self.selectedMedPaths setObject:[NSNumber numberWithBool:checkedUnchecked] forKey:indexPath];
		cell.accessoryType = checkedUnchecked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
		[self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
	}
}

@end
