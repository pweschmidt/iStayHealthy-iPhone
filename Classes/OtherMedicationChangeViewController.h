//
//  OtherMedicationChangeViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 14/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClinicAddressCell.h"

@class OtherMedication,iStayHealthyRecord;
@interface OtherMedicationChangeViewController : UITableViewController <UIAlertViewDelegate, ClinicAddressCellDelegate>{
    OtherMedication *otherMed;
    NSString *drugName;
    NSString *doseAmount;
@private
    NSString                *name;
    NSNumber                *number;
    NSString                *unit;
    iStayHealthyRecord *record;
}
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *number;
@property (nonatomic, retain) NSString *unit;
@property (nonatomic, assign) OtherMedication *otherMed;
@property (nonatomic, assign) iStayHealthyRecord *record;
- (IBAction) save:					(id) sender;
- (IBAction) showAlertView:			(id) sender;
- (void)removeSQLEntry;
- (NSNumber *)valueFromString:(NSString *)string;
- (id)initWithOtherMedication:(OtherMedication *)_other withMasterRecord:(iStayHealthyRecord *)masterRecord;
@end
