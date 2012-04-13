//
//  ProcedureChangeViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 19/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClinicAddressCell.h"
@class iStayHealthyRecord, Procedures;
@interface ProcedureChangeViewController : UITableViewController<UIAlertViewDelegate, ClinicAddressCellDelegate>{
@private
    Procedures *procedures;
    iStayHealthyRecord *record;
    NSString *name;
    NSString *illness;
    
}
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *illness;
@property (nonatomic, assign) Procedures *procedures;
@property (nonatomic, assign) iStayHealthyRecord *record;
- (IBAction) save:					(id) sender;
- (IBAction) showAlertView:			(id) sender;
- (void)removeSQLEntry;
- (id)initWithProcedure:(Procedures *)_procs withMasterRecord:(iStayHealthyRecord *)masterRecord;
@end
