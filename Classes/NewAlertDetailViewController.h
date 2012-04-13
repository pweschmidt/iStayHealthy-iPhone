//
//  NewAlertDetailViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 14/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>
#import "ClinicAddressCell.h"
#import "RepeatCell.h"
@class SetDateCell, SoundNameCell;

@interface NewAlertDetailViewController : UITableViewController <UIActionSheetDelegate, AVAudioPlayerDelegate, ClinicAddressCellDelegate, RepeatCellDelegate> {
@private
    NSArray *sounds;
    SetDateCell *dateCell;
    SoundNameCell *selectedSoundCell;
    BOOL isFirstLoad;
	NSDate *startTime;
	AVAudioPlayer *player;
    int howMany;
    NSString *alertText;
    NSString *soundName;
}
@property int howMany;
@property BOOL isFirstLoad;
@property (nonatomic, retain) NSString *alertText;
@property (nonatomic, retain) NSString *soundName;
@property (nonatomic, retain) NSArray *sounds;
@property (nonatomic, retain) SetDateCell *dateCell;
@property (nonatomic, retain) SoundNameCell *selectedSoundCell;
@property (nonatomic, assign)	AVAudioPlayer	*player;
@property (nonatomic, retain) NSDate *startTime;
- (IBAction) save:					(id) sender;
- (IBAction) cancel:				(id) sender;
- (void)changeTime;
- (void)loadSoundFile:(NSString *)soundFileName;
- (void)stopPlayer;
@end
