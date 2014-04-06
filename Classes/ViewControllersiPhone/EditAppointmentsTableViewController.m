//
//  EditAppointmentsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/09/2013.
//
//

#import "EditAppointmentsTableViewController.h"
#import "Constants.h"
#import "CoreDataManager.h"
//#import "Appointments+Handling.h"
#import "Contacts+Handling.h"
#import "Utilities.h"
#import "UILabel+Standard.h"


@interface EditAppointmentsTableViewController ()
@property (nonatomic, strong) NSArray *editMenu;
@property (nonatomic, strong) NSArray *clinics;
@property (nonatomic, strong) NSMutableArray *titleStrings;
@end

@implementation EditAppointmentsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
     currentClinics:(NSArray *)currentClinics
      managedObject:(NSManagedObject *)managedObject
{
	self = [super initWithStyle:style managedObject:managedObject hasNumericalInput:NO];
	if (nil != self)
	{
		if (nil == currentClinics)
		{
			_clinics = [NSArray array];
		}
		else
		{
			_clinics = currentClinics;
		}
	}
	return self;
}

- (void)populateValues
{
	self.editMenu = @[kAppointmentClinic, kAppointmentNotes];
	self.titleStrings = [NSMutableArray arrayWithCapacity:self.editMenu.count];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self populateValues];
	if (self.isEditMode)
	{
		self.navigationItem.title = NSLocalizedString(@"Edit Appointment", nil);
	}
	else
	{
		self.navigationItem.title = NSLocalizedString(@"New Appointment", nil);
	}
}

- (void)save:(id)sender
{
	[super save:sender];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (0 == indexPath.section)
	{
		return ([self indexPathHasPicker:indexPath] ? kBaseDateCellRowHeight : self.tableView.rowHeight);
	}
	else
	{
		return ([self indexPathHasEndDatePicker:indexPath] ? kBaseDateCellRowHeight : self.tableView.rowHeight);
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 40;
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
		return ([self hasInlineEndDatePicker] ? 2 : 1);
	}
	else
	{
		return self.clinics.count;
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
		identifier = [NSString stringWithFormat:kEndDateCellRowIdentifier];
		if ([self hasInlineEndDatePicker])
		{
			identifier = [NSString stringWithFormat:@"DatePickerEndCell"];
		}
	}
	else
	{
		identifier = [NSString stringWithFormat:@"AppointmentCell%d", indexPath.row];
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
		[self configureDateCell:cell indexPath:indexPath dateType:DateOnly];
	}
	else if (1 == indexPath.section)
	{
		[self configureEndDateCell:cell indexPath:indexPath dateType:DateOnly];
	}
	else
	{
	}
	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *headerView = [[UIView alloc]
	                      initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 36)];
	headerView.backgroundColor = [UIColor clearColor];
	UILabel *headerLabel = [UILabel standardLabel];
	headerLabel.frame = CGRectMake(20, 0, headerView.frame.size.width - 40, headerView.frame.size.height);
	if (0 == section)
	{
		headerLabel.text = NSLocalizedString(@"Appointment Start", nil);
	}
	else
	{
		headerLabel.text = NSLocalizedString(@"Appointment End", nil);
	}
	[headerView addSubview:headerLabel];
	return headerView;
}

@end
