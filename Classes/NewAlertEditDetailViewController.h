//
//  NewAlertEditDetailViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 15/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>
#import "ClinicAddressCell.h"
@class SetDateCell, SoundNameCell;

@interface NewAlertEditDetailViewController : UITableViewController<UIActionSheetDelegate, AVAudioPlayerDelegate, UIAlertViewDelegate,ClinicAddressCellDelegate>{
@private
    NSArray *sounds;
    SetDateCell *dateCell;
    SoundNameCell *selectedSoundCell;
    BOOL isFirstLoad;
    int firstSelectedRow;
	NSDate *startTime;
	AVAudioPlayer *player;
    NSString *alertText;
    NSString *soundName;
	UILocalNotification *__unsafe_unretained previousNotification;	    
}
@property (nonatomic, unsafe_unretained) UILocalNotification *previousNotification;
@property BOOL isFirstLoad;
@property int firstSelectedRow;
@property (nonatomic, strong) NSString *alertText;
@property (nonatomic, strong) NSString *soundName;
@property (nonatomic, strong) NSArray *sounds;
@property (nonatomic, strong) SetDateCell *dateCell;
@property (nonatomic, strong) SoundNameCell *selectedSoundCell;
@property (nonatomic, strong)	AVAudioPlayer	*player;
@property (nonatomic, strong) NSDate *startTime;
- (IBAction) done:					(id) sender;
- (IBAction) showAlertView:			(id) sender;
- (void)removeNotification;
- (void)changeTime;
- (void)loadSoundFile:(NSString *)soundFileName;
- (void)stopPlayer;
- (id)initWithNotification:(UILocalNotification *)notification;
@end
