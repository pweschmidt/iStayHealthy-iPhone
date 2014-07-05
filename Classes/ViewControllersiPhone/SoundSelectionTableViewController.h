//
//  SoundSelectionTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/07/2014.
//
//

#import <UIKit/UIKit.h>
#import "SoundSelector.h"

@interface SoundSelectionTableViewController : UITableViewController
@property (nonatomic, strong) NSString *previousSound;
@property (nonatomic, weak) id <SoundSelector> soundDelegate;
@end
