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
	UILocalNotification *previousNotification;	    
}
@property (nonatomic, assign) UILocalNotification *previousNotification;
@property BOOL isFirstLoad;
@property int firstSelectedRow;
@property (nonatomic, retain) NSString *alertText;
@property (nonatomic, retain) NSString *soundName;
@property (nonatomic, retain) NSArray *sounds;
@property (nonatomic, retain) SetDateCell *dateCell;
@property (nonatomic, retain) SoundNameCell *selectedSoundCell;
@property (nonatomic, assign)	AVAudioPlayer	*player;
@property (nonatomic, retain) NSDate *startTime;
- (IBAction) done:					(id) sender;
- (IBAction) showAlertView:			(id) sender;
- (void)removeNotification;
- (void)changeTime;
- (void)loadSoundFile:(NSString *)soundFileName;
- (void)stopPlayer;
- (id)initWithNotification:(UILocalNotification *)notification;
@end
