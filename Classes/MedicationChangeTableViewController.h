//
//  MedicationChangeTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 16/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwitcherCell.h"
#import "ClinicAddressCell.h"
@class iStayHealthyRecord, Medication, SetDateCell;

@interface MedicationChangeTableViewController : UITableViewController <UIActionSheetDelegate, UIAlertViewDelegate,SwitcherCellProtocol,ClinicAddressCellDelegate> {
    NSDate *date;
    NSString *effectString;
    NSString *medName;
    iStayHealthyRecord *record;
    SetDateCell *dateCell;
    Medication *selectedMedication;
    BOOL isMissed;
    BOOL effectIsSet;
}
@property BOOL isMissed;
@property BOOL effectIsSet;
@property (nonatomic, retain) NSString *effectString;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, assign) NSString *medName;
@property (nonatomic, retain) SetDateCell *dateCell;
@property (nonatomic, assign) iStayHealthyRecord *record;
@property (nonatomic, assign) Medication *selectedMedication;
- (IBAction) save:					(id) sender;
- (IBAction) showAlertView:			(id) sender;
- (void)removeSQLEntry;
- (void)changeDate;
- (id)initWithMasterRecord:(iStayHealthyRecord *)masterRecord withMedication:(Medication *)medication;
@end
