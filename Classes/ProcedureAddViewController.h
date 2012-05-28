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
@property (nonatomic, strong) SetDateCell *dateCell;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) iStayHealthyRecord *record;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *illness;
- (IBAction) save:					(id) sender;
- (IBAction) cancel:				(id) sender;
- (void)changeStartDate;
- (id)initWithRecord:(iStayHealthyRecord *)masterrecord;
@end
