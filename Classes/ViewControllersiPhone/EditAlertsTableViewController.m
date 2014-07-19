//
//  EditAlertsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/09/2013.
//
//

#import "EditAlertsTableViewController.h"
#import "SoundSelectionTableViewController.h"
#import "UILabel+Standard.h"
#import "Menus.h"

@interface EditAlertsTableViewController ()
{
	NSUInteger frequencyIndex;
}
@property (nonatomic, strong) NSArray *editMenu;
@property (nonatomic, strong) NSArray *frequencyArray;
@property (nonatomic, strong) NSMutableArray *titleStrings;
@property (nonatomic, strong) UISegmentedControl *frequencyControl;
@property (nonatomic, strong) UILocalNotification *currentNotification;
@property (nonatomic, strong) NSString *selectedSoundName;
@property (nonatomic, strong) UILabel *soundLabel;
- (void)changeFrequency:(id)sender;
@end

@implementation EditAlertsTableViewController

- (id)  initWithStyle:(UITableViewStyle)style
    localNotification:(UILocalNotification *)localNotification
{
	self = [super initWithStyle:style managedObject:nil hasNumericalInput:NO];
	if (nil != self)
	{
		_currentNotification = localNotification;
		self.isEditMode = (nil != localNotification);
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	if (self.isEditMode)
	{
		self.navigationItem.title = NSLocalizedString(@"Edit Alert", nil);
		if (nil != self.currentNotification)
		{
			self.date = self.currentNotification.fireDate;
			NSString *soundName = self.currentNotification.soundName;
			__block NSString *soundText = nil;
			[[Menus soundFiles] enumerateKeysAndObjectsUsingBlock: ^(NSString *key, NSString *filename, BOOL *stop) {
			    if ([filename isEqualToString:soundName])
			    {
			        soundText = key;
			        *stop = YES;
				}
			}];
			if (nil == soundText)
			{
				soundText = NSLocalizedString(@"Default", nil);
			}
			self.selectedSoundName = soundText;
		}
	}
	else
	{
		self.navigationItem.title = NSLocalizedString(@"New Alert", nil);
		self.selectedSoundName = nil;
	}
	self.editMenu = @[kAlertLabel];
	self.titleStrings = [NSMutableArray arrayWithCapacity:self.editMenu.count];
	self.frequencyArray = @[@"1", @"2", @"3", @"4"];
	self.frequencyControl = [[UISegmentedControl alloc] initWithItems:self.frequencyArray];
	self.frequencyControl.selectedSegmentIndex = 0;
	frequencyIndex = 1;
	[self.frequencyControl addTarget:self
	                          action:@selector(changeFrequency:)
	                forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)save:(id)sender
{
	NSTimeInterval timeInterval = 24.0 / (double)frequencyIndex * 60.0 * 60.0;
	NSString *alertText = NSLocalizedString(@"iStayHealthy Alert", nil);
	UITextField *inputField = [self customTextFieldForTagNumber:[NSNumber numberWithInteger:0]];
	if (nil != inputField)
	{
		alertText = inputField.text;
	}
	NSString *soundFile = nil;
	if (nil == self.selectedSoundName)
	{
		soundFile = UILocalNotificationDefaultSoundName;
	}
	else
	{
		soundFile = [[Menus soundFiles] objectForKey:self.selectedSoundName];
		if (nil == soundFile)
		{
			soundFile = UILocalNotificationDefaultSoundName;
		}
	}

	for (int alarmIndex = 0; alarmIndex < frequencyIndex; alarmIndex++)
	{
		NSTimeInterval addedSeconds = alarmIndex * timeInterval;
		NSDictionary *userDictionary = @{ kAppNotificationIntervalKey: @"daily",
			                              kAppNotificationKey : alertText };

		UILocalNotification *medAlert = [[UILocalNotification alloc]init];
		medAlert.fireDate = (0 == addedSeconds) ? self.date : [self.date dateByAddingTimeInterval:addedSeconds];
		medAlert.timeZone = [NSTimeZone localTimeZone];
		medAlert.repeatInterval = NSDayCalendarUnit;
		medAlert.userInfo = userDictionary;
		medAlert.alertBody = alertText;
		medAlert.alertAction = @"Show me";
		medAlert.soundName = soundFile;

		medAlert.applicationIconBadgeNumber = 1;
		[[UIApplication sharedApplication]scheduleLocalNotification:medAlert];
	}
	__strong id <NotificationsDelegate> strongDelegate = self.notificationsDelegate;
	if (nil != strongDelegate && [strongDelegate respondsToSelector:@selector(updateLocalNotifications)])
	{
		[strongDelegate updateLocalNotifications];
	}
	[self popController];
}

- (void)removeManagedObject
{
	if (!self.isEditMode)
	{
		return;
	}
	[[UIApplication sharedApplication] cancelLocalNotification:self.currentNotification];
	__strong id <NotificationsDelegate> strongDelegate = self.notificationsDelegate;
	if (nil != strongDelegate && [strongDelegate respondsToSelector:@selector(updateLocalNotifications)])
	{
		[strongDelegate updateLocalNotifications];
	}
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
		return 1;
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
		identifier = [NSString stringWithFormat:@"AlertCell%ld", (long)indexPath.row];
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
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
			                              reuseIdentifier:identifier];
		}
		if (0 == indexPath.row)
		{
			[self configureDateCell:cell indexPath:indexPath dateType:TimeOnly];
		}
		return cell;
	}
	else if (1 == indexPath.section)
	{
		if (nil == cell)
		{
			cell = [[PWESCustomTextfieldCell alloc] initWithStyle:UITableViewCellStyleDefault
			                                      reuseIdentifier:identifier];
		}
		NSString *localisedText = NSLocalizedString([self.editMenu objectAtIndex:indexPath.row], nil);
		[self configureTableCell:cell
		                   title:localisedText
		               indexPath:indexPath
		       hasNumericalInput:NO];
		return cell;
	}
	else
	{
		if (nil == cell)
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		}
		[self configureSoundCell:cell];
		return cell;
	}
}

- (void)configureSoundCell:(UITableViewCell *)cell
{
	UILabel *soundSelect = (UILabel *)[cell.contentView viewWithTag:10];
	if (nil == soundSelect)
	{
		soundSelect = [UILabel standardLabel];
		soundSelect.frame = CGRectMake(20, 0, 120, self.tableView.rowHeight);
		soundSelect.text = NSLocalizedString(@"Alert Sound", nil);
		soundSelect.tag = 10;
		[cell.contentView addSubview:soundSelect];
	}

	UILabel *soundNameLabel = (UILabel *)[cell.contentView viewWithTag:11];
	if (nil == soundNameLabel)
	{
		soundNameLabel = [UILabel standardLabel];
		soundNameLabel.tag = 11;
		soundNameLabel.frame = CGRectMake(150, 0, 140, self.tableView.rowHeight);
		if (nil != self.selectedSoundName)
		{
			soundNameLabel.text = self.selectedSoundName;
		}
		[cell.contentView addSubview:soundNameLabel];
	}
	self.soundLabel = soundNameLabel;

	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)configureTableCell:(PWESCustomTextfieldCell *)cell
                     title:(NSString *)title
                 indexPath:(NSIndexPath *)indexPath
         hasNumericalInput:(BOOL)hasNumericalInput
{
	[super configureTableCell:cell title:title indexPath:indexPath segmentIndex:0 hasNumericalInput:hasNumericalInput];
	NSString *value = nil;
	if (nil != self.currentNotification)
	{
		value = self.currentNotification.alertBody;
	}
	NSNumber *taggedViewNumber = [self tagNumberForIndex:indexPath.row segment:0];
	UITextField *textField = [self customTextFieldForTagNumber:taggedViewNumber];
	if (nil != textField && nil != value)
	{
		textField.text = value;
		textField.textColor = [UIColor blackColor];
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
	if (2 > section)
	{
		footerView.frame = CGRectMake(0, 0, tableView.frame.size.width, 10);
		footerView.backgroundColor = [UIColor clearColor];
		return footerView;
	}
	footerView.frame = CGRectMake(0, 0, tableView.frame.size.width, 40);
	UILabel *label = [[UILabel alloc]
	                  initWithFrame:CGRectMake(20, 10, tableView.bounds.size.width - 40, 20)];
	label.backgroundColor = [UIColor clearColor];
	label.text = NSLocalizedString(@"Per Day", nil);
	label.textColor = TEXTCOLOUR;
	label.textAlignment = NSTextAlignmentJustified;
	label.font = [UIFont systemFontOfSize:15];
	[footerView addSubview:label];
	self.frequencyControl.frame = CGRectMake(20, 35, tableView.bounds.size.width - 40, 25);
	[footerView addSubview:self.frequencyControl];
	return footerView;
}

- (void)changeFrequency:(id)sender
{
	if ([sender isKindOfClass:[UISegmentedControl class]])
	{
		UISegmentedControl *segmenter = (UISegmentedControl *)sender;
		frequencyIndex = segmenter.selectedSegmentIndex + 1;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (2 == indexPath.section)
	{
		SoundSelectionTableViewController *controller = [[SoundSelectionTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
		controller.previousSound = self.selectedSoundName;
		controller.soundDelegate = self;
		[self.navigationController pushViewController:controller animated:YES];
	}
	else
	{
		[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
}

- (void)selectedSound:(NSString *)soundName
{
	self.selectedSoundName = soundName;
	self.soundLabel.text = soundName;
}

@end
