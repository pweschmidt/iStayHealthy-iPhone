//
//  MedAlertDetailViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 29/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MedAlertDetailViewController.h"
#import "EditableTableCell.h"
#import "iStayHealthyAppDelegate.h"
#import "GeneralSettings.h"


@implementation MedAlertDetailViewController
@synthesize timePicker, labelCell, soundCell, repeatCell;

#pragma mark -
#pragma mark View lifecycle

/**
 loads/sets up the view
 */
- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = NSLocalizedString(@"Add Alert",@"Add Alert");
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                            target:self action:@selector(cancel:)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                            target:self action:@selector(save:)] autorelease];	

	repeatFrequency = 1; //once a day
	timeDifferenceBetweenAlarms = 24.0 * 60.0 * 60.0;
	initialLabel = initialRepeat = initialSound = YES;
	self.timePicker.date = [NSDate date];
}

/**
 when save a new UILocalNotification is generated. This will be based on the default timezone.
 if there is a repeat selected then a separate UILocalNotification will be generated for each repeat.
 The frequency is set to 24 hours.
 view is then dismissed
 @id
 */
- (IBAction) save: (id) sender{
#ifdef APPDEBUG
    NSLog(@"MedAlertDetailViewController::save ENTERING");
#endif
	if (0 == repeatFrequency) {
		Class notificationClass = NSClassFromString(@"UILocalNotification");
		if (nil != notificationClass) {
			NSString *alertTimeObject = self.labelCell.editableCellTextField.text;
			NSDictionary *userDictionary = [NSDictionary dictionaryWithObject:alertTimeObject forKey:MEDICATIONALERTKEY];
			
			UILocalNotification *medAlert = [[notificationClass alloc]init];
			medAlert.fireDate = self.timePicker.date;
			medAlert.timeZone = [NSTimeZone defaultTimeZone];
			medAlert.userInfo = userDictionary;
			
			medAlert.alertBody = self.labelCell.editableCellTextField.text;
			medAlert.alertAction = @"Show me";
			if (![self.soundCell.editableCellTextField.text isEqualToString:@"None"]) {
				if ([self.soundCell.editableCellTextField.text isEqualToString:@"default"]) {
					medAlert.soundName = UILocalNotificationDefaultSoundName;
				}
				else {
					medAlert.soundName = self.soundCell.editableCellTextField.text;
				}

			}

				 
			
			medAlert.applicationIconBadgeNumber = 1;
			[[UIApplication sharedApplication]scheduleLocalNotification:medAlert];
			[medAlert release];
		}
	}
	else {
		for (int i = 0; i < repeatFrequency; ++i) {
			NSTimeInterval addedSeconds = i * timeDifferenceBetweenAlarms;
			Class notificationClass = NSClassFromString(@"UILocalNotification");
			if (nil != notificationClass) {
				NSString *alertTimeObject = self.labelCell.editableCellTextField.text;
				NSDictionary *userDictionary = [NSDictionary dictionaryWithObject:alertTimeObject forKey:MEDICATIONALERTKEY];
				
				UILocalNotification *medAlert = [[notificationClass alloc]init];
				medAlert.fireDate = (0 == addedSeconds) ? self.timePicker.date : [self.timePicker.date dateByAddingTimeInterval:addedSeconds];
				medAlert.timeZone = [NSTimeZone defaultTimeZone];
				medAlert.repeatInterval = NSDayCalendarUnit;
				medAlert.userInfo = userDictionary;
				
				medAlert.alertBody = self.labelCell.editableCellTextField.text;
				medAlert.alertAction = @"Show me";
				if (![self.soundCell.editableCellTextField.text isEqualToString:@"None"]) {
					if ([self.soundCell.editableCellTextField.text isEqualToString:@"default"]) {
						medAlert.soundName = UILocalNotificationDefaultSoundName;
					}
					else {
						medAlert.soundName = [NSString stringWithFormat:@"%@.caf",self.soundCell.editableCellTextField.text];
					}
					
				}
				
				medAlert.applicationIconBadgeNumber = 1;
				[[UIApplication sharedApplication]scheduleLocalNotification:medAlert];
				[medAlert release];
			}
		}
	}
	
    
	[self dismissModalViewControllerAnimated:YES];
#ifdef APPDEBUG
    NSLog(@"MedAlertDetailViewController::save LEAVING");
#endif
}

/**
 view is dismissed without generating a UILocalNotification
 @id
 */
- (IBAction) cancel: (id) sender{
#ifdef APPDEBUG
    NSLog(@"MedAlertDetailViewController::cancel ENTERING");
#endif
	[self dismissModalViewControllerAnimated:YES];
#ifdef APPDEBUG
    NSLog(@"MedAlertDetailViewController::cancel LEAVING");
#endif
}



#pragma mark -
#pragma mark Table view data source
/**
  1 section
 @tableView
 @return NSInteger
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

/**
 section 0 has 3 rows
 @tableView
 @section
 @return NSInteger
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}

/**
 loads/sets up the cells
 @tableView
 @indexPath
 @return UITableViewCell
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    EditableTableCell *cell = (EditableTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[EditableTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	
    
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	switch (indexPath.row) {
		case 0:
			self.labelCell = cell;
			self.labelCell.editableCellLabel.text = NSLocalizedString(@"Alert Label",@"Alert Label");
            if (initialLabel) {
                initialLabel = NO;
                self.labelCell.editableCellTextField.text = NSLocalizedString(@"Label Text",@"Label Text");                
            }
			self.labelCell.editableCellTextField.keyboardType = UIKeyboardTypeDefault;
			break;
		case 1:
			self.repeatCell = cell;
			self.repeatCell.editableCellLabel.text = NSLocalizedString(@"Repeats",@"Repeats");
			if (initialRepeat) {
				initialRepeat = NO;
				self.repeatCell.editableCellTextField.text = NSLocalizedString(@"Every 24 hours",@"Every 24 hours");
			}
			self.repeatCell.editableCellTextField.enabled = NO;
			break;
		case 2:
			self.soundCell = cell;
			self.soundCell.editableCellLabel.text = NSLocalizedString(@"Sound",@"Sound");
			if (initialSound) {
				initialSound = NO;
				self.soundCell.editableCellTextField.text = NSLocalizedString(@"default",@"default");
			}
			self.soundCell.editableCellTextField.enabled = NO;
			break;
	}
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return (UITableViewCell *)cell;
}


/**
 this is calls the delegate to set the repeat frequency
 @repeatText
 */
- (void)setRepeatIntervalText:(NSString *)repeatText{
#ifdef APPDEBUG
    NSLog(@"MedAlertDetailViewController::setRepeatIntervalText repeatText =%@",repeatText);
#endif
    NSString *repeats = repeatText;
    if (nil == repeats) {
        return;
    }
    if ([repeats isEqualToString:@""]) {
        return;
    }
#ifdef APPDEBUG
	NSLog(@"in setRepeatIntervalText. Text to set is %@",repeats);
#endif
	self.repeatCell.editableCellTextField.text = repeats;
	if ([repeats isEqualToString:@"Never"]) {
		repeatFrequency = 0;
	}
	else if([repeats isEqualToString:@"Every 24 hours"]){
		repeatFrequency = 1;
		timeDifferenceBetweenAlarms = 24.0 * 60.0 * 60.0;
	}
	else if([repeats isEqualToString:@"Every 12 hours"]){
		repeatFrequency = 2;
		timeDifferenceBetweenAlarms = 12.0 * 60.0 * 60.0;
	}
	else if([repeats isEqualToString:@"Every 8 hours"]){
		repeatFrequency = 3;
		timeDifferenceBetweenAlarms = 8.0 * 60.0 * 60.0;
	}
	else if([repeats isEqualToString:@"Every 6 hours"]){
		repeatFrequency = 4;
		timeDifferenceBetweenAlarms = 6.0 * 60.0 * 60.0;
	}	
	
	[self.tableView reloadData];
}

/**
 this calls the delegate to set the sound file name
 @soundFileName
 */
- (void)setSoundFileName:(NSString *)soundFileName{
    NSString *sounds = soundFileName;
#ifdef APPDEBUG
    NSLog(@"MedAlertDetailViewController::setSoundFileName soundfile =%@",sounds);
#endif
    if(nil == sounds)
        return;
    if([sounds isEqualToString:@""])
        return;
	self.soundCell.editableCellTextField.text = sounds;
	[self.tableView reloadData];
}

/**
 this creates the RepeatDetailViewController
 */
- (void)pushRepeatDetailViewController{
	RepeatAlertDetailViewController *repeatController = [[[RepeatAlertDetailViewController alloc] initWithNibName:@"RepeatAlertDetailViewController" bundle:nil]autorelease];
	[self.navigationController pushViewController:repeatController animated:YES];
	[repeatController setDelegate:self];
	
}


/**
 this creates the SoundSelectDetailViewController
 */
- (void)pushSoundDetailViewController{
	SoundSelectDetailViewController *soundController = [[[SoundSelectDetailViewController alloc] initWithNibName:@"SoundSelectDetailViewController" bundle:nil]autorelease];
	[self.navigationController pushViewController:soundController animated:YES];
	[soundController setDelegate:self];
}

#pragma mark -
#pragma mark Table view delegate
/**
 select row 1 == create RepeatDetailViewController
 select row 2 (last row) == create SoundSelectDetailViewController
 @tableView
 @indexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.row) {
		case 1:
			[self pushRepeatDetailViewController];
			break;
		case 2:
			[self pushSoundDetailViewController];
			break;

	}
}


#pragma mark -
#pragma mark Memory management
/**
 handles memory warnings
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 unload view
 */
- (void)viewDidUnload {
	[super viewDidUnload];
#ifdef APPDEBUG
    NSLog(@"MedAlertDetailViewController::viewDidUnload");
#endif
	self.timePicker = nil;
	self.labelCell = nil;
	self.soundCell = nil;
	self.repeatCell = nil;
}

/**
 dealloc
 */
- (void)dealloc {
    [super dealloc];
#ifdef APPDEBUG
    NSLog(@"MedAlertDetailViewController::dealloc");
#endif
	[timePicker release];
	[labelCell release];
	[soundCell release];
	[repeatCell release];
}


@end

