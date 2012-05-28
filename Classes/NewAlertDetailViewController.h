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
@property (nonatomic, strong) NSString *alertText;
@property (nonatomic, strong) NSString *soundName;
@property (nonatomic, strong) NSArray *sounds;
@property (nonatomic, strong) SetDateCell *dateCell;
@property (nonatomic, strong) SoundNameCell *selectedSoundCell;
@property (nonatomic, strong)	AVAudioPlayer	*player;
@property (nonatomic, strong) NSDate *startTime;
- (IBAction) save:					(id) sender;
- (IBAction) cancel:				(id) sender;
- (void)changeTime;
- (void)loadSoundFile:(NSString *)soundFileName;
- (void)stopPlayer;
@end
