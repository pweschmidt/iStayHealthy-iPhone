//
//  NewAlertDetailViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 14/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NewAlertDetailViewController.h"
#import "SetDateCell.h"
#import "SoundNameCell.h"
#import "iStayHealthyAppDelegate.h"
#import "GeneralSettings.h"

@implementation NewAlertDetailViewController
@synthesize sounds = _sounds;
@synthesize dateCell = _dateCell;
@synthesize selectedSoundCell = _selectedSoundCell;
@synthesize howMany = _howMany;
@synthesize isFirstLoad = _isFirstLoad;
@synthesize player = _player;
@synthesize startTime = _startTime;
@synthesize alertText = _alertText;
@synthesize soundName = _soundName;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    self = [super initWithNibName:@"NewAlertDetailViewController" bundle:nil];
    if (self)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"SoundList" ofType:@"plist"];
//        NSArray *tmpSoundList = [[[NSArray alloc]initWithContentsOfFile:path]autorelease];
        self.sounds = [NSArray arrayWithContentsOfFile:path];
        self.isFirstLoad = YES;
        self.player = nil;
        self.howMany = 1;
        self.startTime = [NSDate date];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

/**
 dealloc
 */

#pragma mark - View lifecycle

/**
 viewDidLoad
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.title = NSLocalizedString(@"Add Alert",@"Add Alert");
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                              target:self action:@selector(cancel:)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] 
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                               target:self action:@selector(save:)];	
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SoundList" ofType:@"plist"];
    self.sounds = [NSArray arrayWithContentsOfFile:path];
    self.isFirstLoad = YES;
//    self.player = nil;
    self.howMany = 1;
    self.startTime = [NSDate date];
}

#if  defined(__IPHONE_5_1) || defined (__IPHONE_5_0)
- (void)viewDidUnload
{
    self.sounds = nil;
    self.dateCell = nil;
    self.selectedSoundCell = nil;
    self.startTime = nil;
    self.alertText = nil;
    self.soundName = nil;
    [super viewDidUnload];
}
#endif

/**
 create UINotifications for selected options and then dismiss view
 @id
 */
- (IBAction) save:(id)sender
{
    [self stopPlayer];
    Class notificationClass = NSClassFromString(@"UILocalNotification");
    if (nil == notificationClass)
    {
        [self dismissModalViewControllerAnimated:YES];
        return;
    }
    NSTimeInterval timeInterval = 24.0/(double)self.howMany * 60.0 * 60.0;
    for (int alarmIndex = 0; alarmIndex < self.howMany; alarmIndex++)
    {
        NSTimeInterval addedSeconds = alarmIndex * timeInterval;
        NSDictionary *userDictionary = [NSDictionary dictionaryWithObject:self.alertText forKey:MEDICATIONALERTKEY];
        
        UILocalNotification *medAlert = [[notificationClass alloc]init];
        medAlert.fireDate = (0 == addedSeconds) ? self.startTime : [self.startTime dateByAddingTimeInterval:addedSeconds];
        medAlert.timeZone = [NSTimeZone localTimeZone];
        medAlert.repeatInterval = NSDayCalendarUnit;
        medAlert.userInfo = userDictionary;
        
        medAlert.alertBody = self.alertText;
        medAlert.alertAction = @"Show me";
        if ([self.soundName isEqualToString:@"default"])
        {
            medAlert.soundName = UILocalNotificationDefaultSoundName;
        }
        else
        {
            medAlert.soundName = [NSString stringWithFormat:@"%@.caf",self.soundName];
        }
        
        medAlert.applicationIconBadgeNumber = 1;
        [[UIApplication sharedApplication]scheduleLocalNotification:medAlert];
#ifdef APPDEBUG
        NSLog(@"NewAlertDetailViewController::save the alert setting is %@",medAlert);
#endif
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

/**
 view is dismissed without generating a UILocalNotification
 @id
 */
- (IBAction) cancel: (id) sender
{
    [self stopPlayer];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - ClinicAddressCellDelegate Protocol implementation
- (void)setValueString:(NSString *)valueString withTag:(int)tag
{
    if (10 == tag)
    {
        self.alertText = valueString;
    }
}

- (void)setUnitString:(NSString *)unitString
{
    //nothing today
}

- (void)setRepeats:(int)repeats
{
    self.howMany = repeats;
}


#pragma mark -
#pragma mark datepicker code
/**
 brings up a new view to change the date
 */
- (void)changeTime
{
	NSString *title = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? @"\n\n\n\n\n\n\n\n\n" : @"\n\n\n\n\n\n\n\n\n\n\n\n" ;
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Set",nil), nil];
	[actionSheet showInView:self.view];
	
	
	UIDatePicker *datePicker = [[UIDatePicker alloc] init];
	datePicker.tag = 101;
	datePicker.datePickerMode = UIDatePickerModeTime;
    datePicker.minuteInterval = 5;
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
	
	NSString *timestamp = [formatter stringFromDate:datePicker.date];
	self.dateCell.value.text = timestamp;
	self.startTime = datePicker.date;
}


#pragma mark - Table view data source
/**
 number of sections is 2
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

/**
 1st section has 3 rows: Set Time, Label, Repeats
 2nd section has 1 row per sound file
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (3 == section)
    {
        return [self.sounds count];
    }
    else
    {
        return 1;
    }
}

/**
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (3 == section)
    {
        return NSLocalizedString(@"Sound Selection", @"Sound Selection");
    }
    else
    {
        return @"";
    }
}


/**
 for viralload we get more height as with have a togglebutton in there
 @tableView
 @indexPath
 @return height as CGFloat
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        return 60;
    }
	else if (3 == indexPath.section)
    {
        return 44.0;
	}
	return 48.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        NSString *identifier = @"SetDateCell";
        SetDateCell *timeCell = (SetDateCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == timeCell)
        {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"SetDateCell"
                                                                owner:self
                                                              options:nil];
            for (id currentObject in cellObjects)
            {
                if ([currentObject isKindOfClass:[SetDateCell class]])
                {
                    timeCell = (SetDateCell *)currentObject;
                    break;
                }
            }  
        }
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HH:mm";
        [[timeCell value]setText:[formatter stringFromDate:self.startTime]];
        [timeCell setTag:indexPath.row];
        timeCell.labelImageView.image = [UIImage imageNamed:@"alarm.png"];
        self.dateCell = timeCell;
        return timeCell;
    }
    if (1 == indexPath.section)
    {
        NSString *identifier = @"ClinicAddressCell";
        ClinicAddressCell *clinicCell = (ClinicAddressCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == clinicCell)
        {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"ClinicAddressCell"
                                                                owner:self
                                                              options:nil];
            for (id currentObject in cellObjects)
            {
                if ([currentObject isKindOfClass:[ClinicAddressCell class]])
                {
                    clinicCell = (ClinicAddressCell *)currentObject;
                    break;
                }
            }  
            [clinicCell setDelegate:self];
        }
        [[clinicCell title]setText:NSLocalizedString(@"Alert Label", @"Alert Label")];
        [[clinicCell valueField]setText:NSLocalizedString(@"Label Text", @"Label Text")];
        [clinicCell setTag:10];
        return clinicCell;
    }
    if (2 == indexPath.section)
    {
        NSString *identifier = @"RepeatCell";
        RepeatCell *repeatCell = (RepeatCell *)[tableView dequeueReusableCellWithIdentifier:identifier];        
        if (nil == repeatCell)
        {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"RepeatCell"
                                                                owner:self
                                                              options:nil];
            for (id currentObject in cellObjects)
            {
                if ([currentObject isKindOfClass:[RepeatCell class]])
                {
                    repeatCell = (RepeatCell *)currentObject;
                    break;
                }
            }  
            [repeatCell setDelegate:self];
        }
        return repeatCell;
    }
    if (3 == indexPath.section)
    {
        NSString *identifier = @"SoundNameCell";
        SoundNameCell *soundCell = (SoundNameCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == soundCell)
        {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"SoundNameCell"
                                                                owner:self
                                                              options:nil];
            for (id currentObject in cellObjects) {
                if ([currentObject isKindOfClass:[SoundNameCell class]])
                {
                    soundCell = (SoundNameCell *)currentObject;
                    break;
                }
            }  
        }
        if (0 == indexPath.row && self.isFirstLoad)
        {
            self.isFirstLoad = NO;
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

/**
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self stopPlayer];
    if (0 == indexPath.section)
    {
        [self changeTime];
    }
    if(3 == indexPath.section)
    {
        if(nil != self.selectedSoundCell)
            self.selectedSoundCell.accessoryType = UITableViewCellAccessoryNone;
        SoundNameCell *selectedCell = (SoundNameCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        int row = indexPath.row;
        NSString *name = (NSString *)[self.sounds objectAtIndex:row];
        selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
        if (![name isEqualToString:@"default"])
        {
            [self loadSoundFile:name];
            if (self.player && !self.player.playing)
            {
                [self.player prepareToPlay];
                [self.player play];
            }
        }
        self.selectedSoundCell = selectedCell;        
        self.soundName = name;
        [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
    }
}

#pragma mark - Audio stuff

/**
 loads the sound file
 @soundFileName
 */
- (void)loadSoundFile:(NSString *)soundFileName
{
#ifdef APPDEBUG
    NSLog(@"NewAlertDetailViewController::loadSoundFile with sound file %@",soundFileName);
#endif
	if ([soundFileName isEqualToString:@"default"])
    {
        return;
	}
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:soundFileName ofType:@"caf"]];	
    NSError *err;
	self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&err];
	if (self.player) {
		self.player.numberOfLoops = 0;
		self.player.delegate = self;
	}
}

/**
 */
- (void)stopPlayer
{
    if(nil == self.player)
        return;
    if(!self.player.playing)
        return;
    [self.player stop];
}

@end
