//
//  OtherMedsDetailViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/08/2012.
//
//

#import <UIKit/UIKit.h>
#import "ClinicAddressCell.h"
@class iStayHealthyRecord, SetDateCell, OtherMedication, DosageCell;

@interface OtherMedsDetailViewController : UITableViewController <UIActionSheetDelegate, UIAlertViewDelegate, ClinicAddressCellDelegate>
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) iStayHealthyRecord *record;
@property (nonatomic, strong) OtherMedication *otherMeds;
@property (nonatomic, strong) SetDateCell *setDateCell;
@property (nonatomic, strong) DosageCell *dosageCell;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSString *unit;
- (IBAction) save:					(id) sender;
- (IBAction) cancel:				(id) sender;
- (void)changeStartDate;
- (void)removeSQLEntry;
- (IBAction) showAlertView:			(id) sender;
- (id)initWithOtherMedication:(OtherMedication *)otherMeds
             withMasterRecord:(iStayHealthyRecord *)masterRecord;
- (id)initWithRecord:(iStayHealthyRecord *)masterrecord;

@end
