//
//  ProcedureAddViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 19/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClinicAddressCell.h"
@class iStayHealthyRecord, SetDateCell;

@interface ProcedureAddViewController : UITableViewController<UIActionSheetDelegate, ClinicAddressCellDelegate>{
@private
	SetDateCell			*dateCell;
	NSDate *startDate;
	iStayHealthyRecord *record;
    NSString *name;
    NSString *illness;
}
@property (nonatomic, retain) SetDateCell *dateCell;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, assign) iStayHealthyRecord *record;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *illness;
- (IBAction) save:					(id) sender;
- (IBAction) cancel:				(id) sender;
- (void)changeStartDate;
- (id)initWithRecord:(iStayHealthyRecord *)masterrecord;
@end
