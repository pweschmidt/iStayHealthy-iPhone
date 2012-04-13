//
//  MedAlertEditViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 29/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundSelectDetailViewController.h"

@class EditableTableCell;

@interface MedAlertEditViewController : UITableViewController <SoundSelectDelegate>{
	UIDatePicker *timePicker;
	EditableTableCell *labelCell;
	EditableTableCell *soundCell;
	UILocalNotification *previousNotification;	
    BOOL initialLabel;
    BOOL initialSound;
}
@property (nonatomic, retain) UILocalNotification *previousNotification;
@property (nonatomic, retain) IBOutlet UIDatePicker *timePicker;
@property (nonatomic, retain) IBOutlet EditableTableCell *labelCell;
@property (nonatomic, retain) IBOutlet EditableTableCell *soundCell;
- (IBAction) save:					(id) sender;
- (IBAction) cancel:				(id) sender;
- (void)pushSoundDetailViewController;
@end

