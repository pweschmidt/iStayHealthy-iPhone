//
//  MedAlertDetailViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 29/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RepeatAlertDetailViewController.h"
#import "SoundSelectDetailViewController.h"

@class EditableTableCell;


@interface MedAlertDetailViewController : UITableViewController <RepeatAlertDelegate, SoundSelectDelegate>{
	UIDatePicker *timePicker;
	EditableTableCell *labelCell;
	EditableTableCell *soundCell;
	EditableTableCell *repeatCell;
	int repeatFrequency;
	NSTimeInterval timeDifferenceBetweenAlarms;
	BOOL initialRepeat;
	BOOL initialSound;
    BOOL initialLabel;
}
@property (nonatomic, retain) IBOutlet UIDatePicker *timePicker;
@property (nonatomic, retain) IBOutlet EditableTableCell *labelCell;
@property (nonatomic, retain) IBOutlet EditableTableCell *soundCell;
@property (nonatomic, retain) IBOutlet EditableTableCell *repeatCell;
- (IBAction) save:					(id) sender;
- (IBAction) cancel:				(id) sender;
- (void)pushRepeatDetailViewController;
- (void)pushSoundDetailViewController;
@end
