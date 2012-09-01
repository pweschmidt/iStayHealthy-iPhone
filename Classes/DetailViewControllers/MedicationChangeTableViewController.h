//
//  MedicationChangeTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 16/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClinicAddressCell.h"
@class iStayHealthyRecord, Medication, SetDateCell, GradientButton;

@interface MedicationChangeTableViewController : UITableViewController <UIActionSheetDelegate, UIAlertViewDelegate>
@property BOOL startDateChanged;
@property BOOL endDateChanged;
@property NSInteger state;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, weak) SetDateCell *startDateCell;
@property (nonatomic, weak) SetDateCell *endDateCell;
@property (nonatomic, strong) iStayHealthyRecord *record;
@property (nonatomic, strong) Medication *selectedMedication;
@property (nonatomic, strong) NSString *medName;
- (IBAction) save:					(id) sender;
- (IBAction) cancel:				(id) sender;
- (IBAction) showAlertView:			(id) sender;
- (void)removeSQLEntry;
- (void)changeDate;
- (id)initWithMasterRecord:(iStayHealthyRecord *)masterRecord withMedication:(Medication *)medication;
@end
