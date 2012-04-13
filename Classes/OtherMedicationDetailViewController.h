//
//  OtherMedicationDetailViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 10/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClinicAddressCell.h"
#import "DosageCell.h"
@class iStayHealthyRecord, SetDateCell;

@interface OtherMedicationDetailViewController : UITableViewController <UIActionSheetDelegate, ClinicAddressCellDelegate>{
    
@private
	NSDate                  *startDate;
    NSString                *name;
    NSNumber                *number;
    NSString                *unit;
	SetDateCell             *dateCell;
	iStayHealthyRecord *record;
	
}
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *number;
@property (nonatomic, retain) NSString *unit;
@property (nonatomic, retain) SetDateCell *dateCell;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, assign) iStayHealthyRecord *record;
- (IBAction) save:					(id) sender;
- (IBAction) cancel:				(id) sender;
- (void)changeStartDate;
- (id)initWithRecord:(iStayHealthyRecord *)masterrecord;
- (NSNumber *)valueFromString:(NSString *)string;
@end
