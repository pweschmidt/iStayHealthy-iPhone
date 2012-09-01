//
//  OtherMedicationChangeViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 14/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClinicAddressCell.h"

@class OtherMedication,iStayHealthyRecord, SetDateCell;
@interface OtherMedicationChangeViewController : UITableViewController <UIAlertViewDelegate, ClinicAddressCellDelegate, UIActionSheetDelegate>{
    OtherMedication *otherMed;
    NSString *drugName;
    NSString *doseAmount;
    NSDate                  *changeDate;
    NSString                *name;
    NSNumber                *number;
    NSString                *unit;
    iStayHealthyRecord *record;
    SetDateCell *changeDateCell;    
}
@property (nonatomic, strong) SetDateCell *changeDateCell;
@property (nonatomic, strong) NSDate *changeDate;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSString *unit;
@property (nonatomic, strong) OtherMedication *otherMed;
@property (nonatomic, strong) iStayHealthyRecord *record;
- (IBAction) save:					(id) sender;
- (IBAction) showAlertView:			(id) sender;
- (void)removeSQLEntry;
- (NSNumber *)valueFromString:(NSString *)string;
- (id)initWithOtherMedication:(OtherMedication *)_other withMasterRecord:(iStayHealthyRecord *)masterRecord;
- (void)changeStartDate;
@end
