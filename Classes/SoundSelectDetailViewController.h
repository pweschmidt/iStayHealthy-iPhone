//
//  SoundSelectDetailViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/02/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>
#import "SoundSelectCell.h"

@protocol SoundSelectDelegate;

@interface SoundSelectDetailViewController : UITableViewController <AVAudioPlayerDelegate> {
	id<SoundSelectDelegate> delegate;
	BOOL initialLoad;
	NSMutableArray			*availableSounds;
    SoundSelectCell *lastCheckedCell;
	AVAudioPlayer *player;
}

@property (nonatomic, assign) id<SoundSelectDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *availableSounds;
@property (nonatomic, retain) SoundSelectCell *lastCheckedCell;
@property (nonatomic, assign)	AVAudioPlayer	*player;
- (void)playSound:(NSString *)soundFileName;
- (void)loadSoundFile:(NSString *)soundFileName;
@end
@protocol SoundSelectDelegate <NSObject>

- (void)setSoundFileName:(NSString *)soundFileName;

@end
