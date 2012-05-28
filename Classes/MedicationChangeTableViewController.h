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
    NSString *__unsafe_unretained medName;
    NSUInteger state;
    UISwitch *missedSwitch;
    UISwitch *effectSwitch;
    UITableViewCell *missedSwitchCell;
    UITableViewCell *effectSwitchCell;
    ClinicAddressCell *effectsCell;
    iStayHealthyRecord *__unsafe_unretained record;
    SetDateCell *dateCell;
    SetDateCell *missedDateCell;
    SetDateCell *effectDateCell;
    Medication *__unsafe_unretained selectedMedication;
    BOOL isMissed;
    BOOL effectIsSet;
    BOOL dateChanged;
}
@property BOOL dateChanged;
@property BOOL isMissed;
@property BOOL effectIsSet;
@property NSUInteger state;
@property (nonatomic, strong) UISwitch *missedSwitch;
@property (nonatomic, strong) UISwitch *effectSwitch;
@property (nonatomic, strong) NSString *effectString;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *effectDate;
@property (nonatomic, strong) NSDate *missedDate;
@property (nonatomic, unsafe_unretained) NSString *medName;
@property (nonatomic, strong) SetDateCell *dateCell;
@property (nonatomic, strong) SetDateCell *missedDateCell;
@property (nonatomic, strong) SetDateCell *effectDateCell;
@property (nonatomic, strong) UITableViewCell *missedSwitchCell;
@property (nonatomic, strong) UITableViewCell *effectSwitchCell;
@property (nonatomic, strong) ClinicAddressCell *effectsCell;
@property (nonatomic, unsafe_unretained) iStayHealthyRecord *record;
@property (nonatomic, unsafe_unretained) Medication *selectedMedication;
- (IBAction) save:					(id) sender;
- (IBAction) showAlertView:			(id) sender;
- (void)removeSQLEntry;
- (void)changeDate;
- (IBAction)switchSideEffects:(id)sender;
- (IBAction)switchMissedDose:(id)sender;
- (id)initWithMasterRecord:(iStayHealthyRecord *)masterRecord withMedication:(Medication *)medication;
@end
