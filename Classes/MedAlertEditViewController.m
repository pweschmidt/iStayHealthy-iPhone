//
//  MedAlertEditViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 29/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MedAlertEditViewController.h"
#import "EditableTableCell.h"
#import "iStayHealthyAppDelegate.h"


@implementation MedAlertEditViewController
@synthesize timePicker, labelCell, soundCell, previousNotification;

#pragma mark -
#pragma mark View lifecycle

/**
 loads/sets up the view
 */
- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = NSLocalizedString(@"Edit Alert",@"Edit Alert");
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																						   target:self action:@selector(cancel:)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
																							target:self action:@selector(save:)] autorelease];	
    initialLabel = initialSound = YES;
		
}

/**
 the alert time is set to the one from the original UILocalNotification
 @animated
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	if (nil == previousNotification) {
		return;
	}
    if (self.labelCell && initialLabel) {
        initialLabel = NO;
        self.labelCell.editableCellTextField.text = previousNotification.alertBody;
    }
    if (self.soundCell && initialSound) {
        initialSound = NO;
        NSString *currentSoundName = previousNotification.soundName;
        if ([currentSoundName hasPrefix:@"UILocalNotificationDefaultSoundName"]) {            
            currentSoundName = @"default";
        }
        NSArray *strings = [currentSoundName componentsSeparatedByString:@"."];
        if (2 == [strings count]) {
            self.soundCell.editableCellTextField.text = (NSString *)[strings objectAtIndex:0];
        }
        else
            self.soundCell.editableCellTextField.text = currentSoundName;
    }
	timePicker.date = previousNotification.fireDate;
}

/**
 this is supposed to modify an existing alert.
 However, UILocalNotifications don't work that way. Instead, when any changes are made, the
 selected UILocalNotification gets cancelled and replaced by the one generated in this method.
 view is then dismissed
 @id
 */
- (IBAction) save:					(id) sender{
	Class notificationClass = NSClassFromString(@"UILocalNotification");
	if (nil != notificationClass) {
		NSString *alertTimeObject = self.labelCell.editableCellTextField.text;
		NSDictionary *userDictionary = [NSDictionary dictionaryWithObject:alertTimeObject forKey:MEDICATIONALERTKEY];
		
		UILocalNotification *medAlert = [[notificationClass alloc]init];
		medAlert.fireDate = self.timePicker.date;
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
                if ([self.soundCell.editableCellTextField.text hasSuffix:@".caf"]) {
                    medAlert.soundName = self.soundCell.editableCellTextField.text;
        
                }
                else
                    medAlert.soundName = [NSString stringWithFormat:@"%@.caf",self.soundCell.editableCellTextField.text];
			}
			
		}
		
		medAlert.applicationIconBadgeNumber = 1;
		[[UIApplication sharedApplication]scheduleLocalNotification:medAlert];
		[medAlert release];
	}
	if (nil!= previousNotification) {
		[[UIApplication sharedApplication]cancelLocalNotification:previousNotification];
	}
	[self dismissModalViewControllerAnimated:YES];
}

/**
 dismiss without saving
 @id
 */
- (IBAction) cancel:				(id) sender{
	[self dismissModalViewControllerAnimated:YES];
}





#pragma mark -
#pragma mark Table view data source
/**
 only 1 section
 @tableView
 @return NSInteger
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/**
 2 rows 
 @tableView
 @section
 @return NSInteger
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
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
	switch (indexPath.row) {
		case 0:
			self.labelCell = cell;
			self.labelCell.editableCellLabel.text = NSLocalizedString(@"Alert Label",@"Alert Label");
			self.labelCell.editableCellTextField.text = NSLocalizedString(@"Label Text",@"Label Text");
			self.labelCell.editableCellTextField.keyboardType = UIKeyboardTypeDefault;
			break;
		case 1:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			self.soundCell = cell;
			self.soundCell.editableCellLabel.text = NSLocalizedString(@"Sound",@"Sound");
			self.soundCell.editableCellTextField.enabled = NO;
			break;
	}
    
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return (UITableViewCell *)cell;
}


/**
 loads the SoundSelectDetailViewController
 */
- (void)pushSoundDetailViewController{
	SoundSelectDetailViewController *soundController = [[SoundSelectDetailViewController alloc] initWithNibName:@"SoundSelectDetailViewController" bundle:nil];
	[self.navigationController pushViewController:soundController animated:YES];
	[soundController setDelegate:self];
	[soundController release];
}

/**
 sets the sound file name
 @soundFileName
 */
- (void)setSoundFileName:(NSString *)soundFileName{
	self.soundCell.editableCellTextField.text = soundFileName;
}


#pragma mark -
#pragma mark Table view delegate
/**
 if row 1 is selected we load the SoundSelectDetailViewController
 @tableView
 @indexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (1 == indexPath.row) {
		[self pushSoundDetailViewController];			
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
 unloads the view
 */
- (void)viewDidUnload {
	[super viewDidUnload];
 }

/**
 dealloc
 */
- (void)dealloc {
	[previousNotification release];
	[timePicker release];
	[labelCell release];
	[soundCell release];
    [super dealloc];
}


@end

