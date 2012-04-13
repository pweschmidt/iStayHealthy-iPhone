//
//  SoundSelectDetailViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/02/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SoundSelectDetailViewController.h"
#import "SoundSelectCell.h"

@implementation SoundSelectDetailViewController
@synthesize delegate,availableSounds,lastCheckedCell;
@synthesize player;


#pragma mark -
#pragma mark View lifecycle

/**
 loads/setsup the view
 */
- (void)viewDidLoad {
    [super viewDidLoad];
	NSString *path = [[NSBundle mainBundle] pathForResource:@"SoundList" ofType:@"plist"];
	NSMutableArray *tmpSoundList = [[[NSMutableArray alloc]initWithContentsOfFile:path]autorelease];
	self.availableSounds = tmpSoundList;
    lastCheckedCell = nil;
}


/**
 called just before view appears
 @animated
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	initialLoad = YES;
}


#pragma mark -
#pragma mark Table view data source

/**
 @tableView
 @return 1 section
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

/**
 @tableView
 @section
 @return list of sound files
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [availableSounds count];
}

/**
 loads/sets up the cells
 @tableView
 @indexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    SoundSelectCell *cell = (SoundSelectCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[SoundSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	cell.soundNameLabel.text = (NSString *)[availableSounds objectAtIndex:indexPath.row];	

	if (0 == indexPath.row && initialLoad) {
		initialLoad = NO;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        lastCheckedCell = cell;
	}
		
 	cell.selectionStyle= UITableViewCellSelectionStyleGray;
   
    return (UITableViewCell *)cell;
}

/**
 C-function - not Objective C code
*/
void SystemSoundsCompletionProc (
									 SystemSoundID  soundID,
									 void           *clientData)
{
	AudioServicesDisposeSystemSoundID (soundID);
};

/**
 plays the sound of the selected file
 */
- (void)playSound:(NSString *)soundFileName{
	SystemSoundID soundID;
	OSStatus err = kAudioServicesNoError;
#ifdef APPDEBUG
	NSLog(@"SoundSelectDetailViewController::playSound filename = %@",soundFileName);
#endif
	NSURL *soundURL = [[[NSBundle mainBundle] URLForResource:soundFileName withExtension:@"caf"]autorelease];
	err = AudioServicesCreateSystemSoundID((CFURLRef)soundURL, &soundID);
	if (kAudioServicesNoError == err) {
		err = AudioServicesAddSystemSoundCompletion
		(soundID, 
		 NULL, 
		 NULL, 
		 SystemSoundsCompletionProc, 
		 self);
		AudioServicesPlaySystemSound(soundID);
	}
	if (kAudioServicesNoError != err) {
		CFErrorRef error = CFErrorCreate(NULL, kCFErrorDomainOSStatus, err, NULL);
		NSString *errorDescription = (NSString *) CFErrorCopyDescription(error);
		UIAlertView *playErrorAlert = [[[UIAlertView alloc] initWithTitle:@"Play Error" message:errorDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]autorelease];
		[playErrorAlert show];
//		[playErrorAlert release];
//		[errorDescription release];
		CFRelease(error);
	}	
}	

/**
 loads the sound file
 @soundFileName
 */
- (void)loadSoundFile:(NSString *)soundFileName{
	if ([soundFileName isEqualToString:@"None"]) {
		return;
	}
	if ([soundFileName isEqualToString:@"default"]) {
        return;
	}
	NSURL *fileURL = [[[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:soundFileName ofType:@"caf"]]autorelease];	
    NSError *err;
	self.player = [[[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&err]autorelease];	
	if (self.player) {
		self.player.numberOfLoops = 1;
		self.player.delegate = self;
	}
#ifdef APPDEBUG
    NSLog(@"SoundSelectDetailViewController::loadSoundFile %@",err);
#endif
}


#pragma mark -
#pragma mark Table view delegate

/**
 phase out when deselecting
 @id
 */
- (void) deselect: (id) sender
{
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

/**
 create a check tick when selected and set the selected sound name to the filename/cellname
 @tableView
 @indexPath
 */
 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (nil == lastCheckedCell) {
        return;
    }
    lastCheckedCell.accessoryType = UITableViewCellAccessoryNone;
	SoundSelectCell *selectedCell = (SoundSelectCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
#ifdef APPDEBUG
	NSLog(@"in SoundSelectDetailViewController: selected sound file is %@",selectedCell.soundNameLabel.text);
#endif
    
	[self.delegate setSoundFileName:selectedCell.soundNameLabel.text];
    [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
	
	if (self.player && self.player.playing) {
		[player stop];
	}
	if (![selectedCell.soundNameLabel.text isEqualToString:@"default"] && ![selectedCell.soundNameLabel.text isEqualToString:@"None"]) {
		[self loadSoundFile:selectedCell.soundNameLabel.text];
		if (self.player && !self.player.playing) {
			[player play];
		}
	}
    lastCheckedCell = selectedCell;
		
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
 unloads view
 */
- (void)viewDidUnload {
	[super viewDidUnload];
	if (self.player && self.player.playing) {
			[self.player stop];
	}
    lastCheckedCell = nil;
}

/**
 dealloc
 */
- (void)dealloc {
    [super dealloc];
	[availableSounds release];
	[lastCheckedCell release];
}


@end

