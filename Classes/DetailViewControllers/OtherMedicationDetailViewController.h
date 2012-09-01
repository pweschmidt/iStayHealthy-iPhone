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
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSString *unit;
@property (nonatomic, strong) SetDateCell *dateCell;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) iStayHealthyRecord *record;
- (IBAction) save:					(id) sender;
- (IBAction) cancel:				(id) sender;
- (void)changeStartDate;
- (id)initWithRecord:(iStayHealthyRecord *)masterrecord;
- (NSNumber *)valueFromString:(NSString *)string;
@end
