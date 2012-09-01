//
//  RepeatCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 10/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClinicAddressCell.h"

@protocol RepeatCellDelegate;
@interface RepeatCell : UITableViewCell
@property (nonatomic, weak) id<RepeatCellDelegate>repeatCellDelegate;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
- (void)setDelegate:(id)viewControllerDelegate;
- (IBAction)toggleRepeats:(id)sender;
@end
@protocol RepeatCellDelegate <NSObject>

- (void)setRepeats:(int)repeats;

@end