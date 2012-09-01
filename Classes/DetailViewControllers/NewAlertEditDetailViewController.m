//
//  NewAlertEditDetailViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 15/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NewAlertEditDetailViewController.h"
#import "iStayHealthyAppDelegate.h"
#import "GeneralSettings.h"
#import "SetDateCell.h"
#import "SoundNameCell.h"

@implementation NewAlertEditDetailViewController
@synthesize sounds, dateCell, selectedSoundCell, isFirstLoad,firstSelectedRow;
@synthesize player, startTime, alertText, soundName, previousNotification;


- (id)initWithNotification:(UILocalNotification *)notification{
    self = [super initWithNibName:@"NewAlertEditDetailViewController" bundle:nil];
#ifdef APPDEBUG
    NSLog(@"initWithNotification");
#endif
    if (self) {
        self.previousNotification = notification;
        self.alertText = self.previousNotification.alertBody;
        self.soundName = self.previousNotification.soundName;
        self.startTime = self.previousNotification.fireDate;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"SoundList" ofType:@"plist"];
        self.sounds = [NSArray arrayWithContentsOfFile:path];
        self.isFirstLoad = YES;
        self.firstSelectedRow = 0;
        for (int i = 0; i<[self.sounds count]; ++i) {
            if ([self.soundName isEqualToString:(NSString *)[self.sounds objectAtIndex:i]]) {
                self.firstSelectedRow = i;
            }
        }
    }    
    return self;
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/**
 dealloc
 */

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.title = NSLocalizedString(@"Edit Alert",@"Edit Alert");
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemTrash 
                                              target:self action:@selector(showAlertView:)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] 
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                               target:self action:@selector(done:)];	
}

/**
 the alert time is set to the one from the original UILocalNotification
 @animated
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

/**
 */
- (void)viewDidUnload
{
    self.soundName = nil;
    self.dateCell = nil;
    self.selectedSoundCell = nil;
    self.startTime =nil;
    self.alertText = nil;
    [super viewDidUnload];
}

/**
 create UINotifications for selected options and then dismiss view
 @id
 */
- (IBAction) done:(id)sender{
    [self stopPlayer];
#ifdef APPDEBUG
    NSLog(@"NewAlertEditDetailViewController done");
#endif
	if (nil!= self.previousNotification) {
		[[UIApplication sharedApplication]cancelLocalNotification:self.previousNotification];
	}
#ifdef APPDEBUG
    NSLog(@"NewAlertEditDetailViewController removed old notification");
#endif
    NSDictionary *userDictionaries = [NSDictionary dictionaryWithObject:alertText forKey:MEDICATIONALERTKEY];;
    
    UILocalNotification *medAlert = [[UILocalNotification alloc]init];
    medAlert.fireDate = self.startTime;
    medAlert.timeZone = [NSTimeZone defaultTimeZone];
    medAlert.repeatInterval = NSDayCalendarUnit;
    medAlert.userInfo = userDictionaries;
    
    medAlert.alertBody = self.alertText;
    medAlert.alertAction = @"Show me";
    if ([self.soundName isEqualToString:@"default"]) {
        medAlert.soundName = UILocalNotificationDefaultSoundName;
    }
    else {
        medAlert.soundName = [NSString stringWithFormat:@"%@.caf",self.soundName];
    }
        
    
    medAlert.applicationIconBadgeNumber = 1;
    [[UIApplication sharedApplication]scheduleLocalNotification:medAlert];
#ifdef APPDEBUG
    NSLog(@"NewAlertEditDetailViewController added new notification");
#endif
    [self dismissModalViewControllerAnimated:YES];
}

/**
 shows the Alert view when user clicks the Trash button
 */
- (IBAction) showAlertView:			(id) sender{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Delete?", @"Delete?") message:NSLocalizedString(@"Do you want to delete this entry?", @"Do you want to delete this entry?") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"Yes", @"Yes"), nil];
    
    [alert show];    
}

/**
 if user really wants to delete the entry call removeSQLEntry
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:NSLocalizedString(@"Yes", @"Yes")]) {
        [self removeNotification];
    }
}
/**
 view is dismissed without generating a UILocalNotification
 @id
 */
- (void) removeNotification{
    [self stopPlayer];
	if (nil!= self.previousNotification) {
		[[UIApplication sharedApplication]cancelLocalNotification:self.previousNotification];
	}
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark datepicker code
/**
 brings up a new view to change the date
 */
- (void)changeTime{
	NSString *title = @"\n\n\n\n\n\n\n\n\n\n\n\n" ;	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Set",nil), nil];
	[actionSheet showInView:self.view];
	
	
	UIDatePicker *datePicker = [[UIDatePicker alloc] init];
	datePicker.tag = 101;
    datePicker.minuteInterval = 5;
	datePicker.datePickerMode = UIDatePickerModeTime;
    datePicker.date = self.startTime;
	[actionSheet addSubview:datePicker];
}

/**
 sets the label and resultsdate to the one selected
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	UIDatePicker *datePicker = (UIDatePicker *)[actionSheet viewWithTag:101];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"HH:mm";
	self.startTime = datePicker.date;
    
	NSString *timestamp = [formatter stringFromDate:self.startTime];
	self.dateCell.value.text = timestamp;
}

#pragma mark - ClinicAddressCellDelegate Protocol implementation
- (void)setValueString:(NSString *)valueString withTag:(int)tag{
    if (10 == tag) {
        self.alertText = valueString;
    }
}

- (void)setUnitString:(NSString *)unitString{
    //nothing today
}



/**
 number of sections is 2
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

/**
 1st section has 3 rows: Set Time, Label, Repeats
 2nd section has 1 row per sound file
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (2 == section) {
        return [self.sounds count];
    }
    else{
        return 1;
    }
}

/**
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (2 == section) {
        return NSLocalizedString(@"Sound Selection", @"Sound Selection");
    }
    else{
        return @"";
    }
}


/**
 for viralload we get more height as with have a togglebutton in there
 @tableView
 @indexPath
 @return height as CGFloat
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (0 == indexPath.section) {
        return 60;
    }
	else if (2 == indexPath.section) {
        return 44.0;
	}
	return 48.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HH:mm";
        
        NSString *identifier = @"SetDateCell";
        SetDateCell *timeCell = (SetDateCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == timeCell) {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"SetDateCell" owner:self options:nil];
            for (id currentObject in cellObjects) {
                if ([currentObject isKindOfClass:[SetDateCell class]]) {
                    timeCell = (SetDateCell *)currentObject;
                    break;
                }
            }  
        }
        [[timeCell value]setText:[formatter stringFromDate:self.startTime]];
        [timeCell setTag:indexPath.row];
        timeCell.labelImageView.image = [UIImage imageNamed:@"alarm.png"];
        self.dateCell = timeCell;
        return timeCell;
    }
    if (1 == indexPath.section) {
        NSString *identifier = @"ClinicAddressCell";
        ClinicAddressCell *clinicCell = (ClinicAddressCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == clinicCell) {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"ClinicAddressCell" owner:self options:nil];
            for (id currentObject in cellObjects) {
                if ([currentObject isKindOfClass:[ClinicAddressCell class]]) {
                    clinicCell = (ClinicAddressCell *)currentObject;
                    break;
                }
            }  
            [clinicCell setDelegate:self];
        }
        [[clinicCell title]setText:NSLocalizedString(@"Alert Label", @"Alert Label")];
        [[clinicCell valueField]setText:self.alertText];
        [clinicCell setTag:10];
        return clinicCell;
    }
    if (2 == indexPath.section) {
        NSString *identifier = @"SoundNameCell";
        SoundNameCell *soundCell = (SoundNameCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == soundCell) {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"SoundNameCell" owner:self options:nil];
            for (id currentObject in cellObjects) {
                if ([currentObject isKindOfClass:[SoundNameCell class]]) {
                    soundCell = (SoundNameCell *)currentObject;
                    break;
                }
            }  
        }
        if (self.firstSelectedRow == indexPath.row && isFirstLoad) {
            isFirstLoad = NO;
            soundCell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.selectedSoundCell = soundCell;
            self.soundName = [self.sounds objectAtIndex:0];
        }
        [[soundCell soundName]setText:[self.sounds objectAtIndex:indexPath.row]];
        return soundCell;
    }
    return nil;
}


#pragma mark - Table view delegate

/**
 sets the timing of the deselect
 @id
 */
- (void) deselect: (id) sender
{
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self stopPlayer];
    if (0 == indexPath.section) {
        [self changeTime];
    }
    if(2 == indexPath.section){
        if(nil != selectedSoundCell)
            selectedSoundCell.accessoryType = UITableViewCellAccessoryNone;
        SoundNameCell *selectedCell = (SoundNameCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        int row = indexPath.row;
        NSString *name = (NSString *)[self.sounds objectAtIndex:row];
        selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
        if (![name isEqualToString:@"default"]) {
            [self loadSoundFile:name];
            if (self.player && !self.player.playing) {
                [self.player prepareToPlay];
                [self.player play];
            }
        }
        self.selectedSoundCell = selectedCell;        
        self.soundName = name;
        [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
    }
}

/**
 loads the sound file
 @soundFileName
 */
- (void)loadSoundFile:(NSString *)soundFileName{
#ifdef APPDEBUG
    NSLog(@"NewAlertDetailViewController::loadSoundFile with sound file %@",soundFileName);
#endif
	if ([soundFileName isEqualToString:@"default"]) {
        return;
	}
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:soundFileName ofType:@"caf"]];	
    NSError *err;
	player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&err];	
	if (player) {
		player.numberOfLoops = 0;
		player.delegate = self;
	}
}

/**
 */
- (void)stopPlayer{
    if(!player)
        return;
    if(!player.playing)
        return;
    [player stop];
}


@end
