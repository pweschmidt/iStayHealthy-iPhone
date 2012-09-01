//
//  ProcedureChangeViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 19/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClinicAddressCell.h"
@class iStayHealthyRecord, Procedures, SetDateCell;
@interface ProcedureChangeViewController : UITableViewController<UIAlertViewDelegate, ClinicAddressCellDelegate, UIActionSheetDelegate>{
@private
	SetDateCell			*changeDateCell;
	NSDate *changeDate;
    Procedures *procedures;
    iStayHealthyRecord *record;
    NSString *name;
    NSString *illness;
    
}
@property (nonatomic, strong) SetDateCell *changeDateCell;
@property (nonatomic, strong) NSDate *changeDate;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *illness;
@property (nonatomic, strong) Procedures *procedures;
@property (nonatomic, strong) iStayHealthyRecord *record;
- (IBAction) save:					(id) sender;
- (IBAction) showAlertView:			(id) sender;
- (void)removeSQLEntry;
- (void)changeStartDate;
- (id)initWithProcedure:(Procedures *)_procs withMasterRecord:(iStayHealthyRecord *)masterRecord;
@end
