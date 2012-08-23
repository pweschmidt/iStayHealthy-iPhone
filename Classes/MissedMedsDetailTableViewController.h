//
//  MissedMedsDetailTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/08/2012.
//
//

#import <UIKit/UIKit.h>
@class iStayHealthyRecord, MissedMedication, SetDateCell;

@interface MissedMedsDetailTableViewController : UITableViewController<UIActionSheetDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) NSDate *missedDate;
@property (nonatomic, strong) iStayHealthyRecord *record;
@property (nonatomic, strong) MissedMedication *missedMeds;
@property (nonatomic, strong) SetDateCell *setDateCell;
- (IBAction) save:					(id) sender;
- (IBAction) cancel:				(id) sender;
- (void)changeDate;
- (void)removeSQLEntry;
- (IBAction) showAlertView:			(id) sender;
- (id)initWithMissedMeds:(MissedMedication *)missed
            masterRecord:(iStayHealthyRecord *)masterRecord;
- (id)initWithRecord:(iStayHealthyRecord *)masterrecord medication:(NSArray *)medArray;

@end
