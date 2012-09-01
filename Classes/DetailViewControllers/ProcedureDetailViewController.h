//
//  ProcedureDetailViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/08/2012.
//
//

#import <UIKit/UIKit.h>
#import "ClinicAddressCell.h"
@class iStayHealthyRecord, SetDateCell, Procedures;

@interface ProcedureDetailViewController : UITableViewController <UIActionSheetDelegate, UIAlertViewDelegate, ClinicAddressCellDelegate>
@property (nonatomic, strong) SetDateCell *dateCell;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) iStayHealthyRecord *record;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *illness;
@property (nonatomic, strong) Procedures *procedures;
- (IBAction) save:					(id) sender;
- (IBAction) cancel:				(id) sender;
- (void)changeStartDate;
- (void)removeSQLEntry;
- (IBAction) showAlertView:			(id) sender;
- (id)initWithRecord:(iStayHealthyRecord *)masterrecord;
- (id)initWithProcedure:(Procedures *)procedure masterRecord:(iStayHealthyRecord *)masterRecord;
@end
