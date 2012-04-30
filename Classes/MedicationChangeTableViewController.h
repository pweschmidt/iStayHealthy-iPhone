//
//  MedicationChangeTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 16/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClinicAddressCell.h"
typedef enum{
  CHANGEDATE = 0,
  MISSEDDATE,
  EFFECTSDATE
}DATESWITCH;
@class iStayHealthyRecord, Medication, SetDateCell;

@interface MedicationChangeTableViewController : UITableViewController <UIActionSheetDelegate, UIAlertViewDelegate,ClinicAddressCellDelegate> {
    NSDate *date;
    NSDate *effectDate;
    NSDate *missedDate;
    NSString *effectString;
    NSString *medName;
    NSUInteger state;
    UISwitch *missedSwitch;
    UISwitch *effectSwitch;
    UITableViewCell *missedSwitchCell;
    UITableViewCell *effectSwitchCell;
    ClinicAddressCell *effectsCell;
    iStayHealthyRecord *record;
    SetDateCell *dateCell;
    SetDateCell *missedDateCell;
    SetDateCell *effectDateCell;
    Medication *selectedMedication;
    BOOL isMissed;
    BOOL effectIsSet;
    BOOL dateChanged;
}
@property BOOL dateChanged;
@property BOOL isMissed;
@property BOOL effectIsSet;
@property NSUInteger state;
@property (nonatomic, retain) UISwitch *missedSwitch;
@property (nonatomic, retain) UISwitch *effectSwitch;
@property (nonatomic, retain) NSString *effectString;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSDate *effectDate;
@property (nonatomic, retain) NSDate *missedDate;
@property (nonatomic, assign) NSString *medName;
@property (nonatomic, retain) SetDateCell *dateCell;
@property (nonatomic, retain) SetDateCell *missedDateCell;
@property (nonatomic, retain) SetDateCell *effectDateCell;
@property (nonatomic, retain) UITableViewCell *missedSwitchCell;
@property (nonatomic, retain) UITableViewCell *effectSwitchCell;
@property (nonatomic, retain) ClinicAddressCell *effectsCell;
@property (nonatomic, assign) iStayHealthyRecord *record;
@property (nonatomic, assign) Medication *selectedMedication;
- (IBAction) save:					(id) sender;
- (IBAction) showAlertView:			(id) sender;
- (void)removeSQLEntry;
- (void)changeDate;
- (IBAction)switchSideEffects:(id)sender;
- (IBAction)switchMissedDose:(id)sender;
- (id)initWithMasterRecord:(iStayHealthyRecord *)masterRecord withMedication:(Medication *)medication;
@end
