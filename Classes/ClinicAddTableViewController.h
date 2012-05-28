//
//  ClinicAddTableViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 18/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClinicAddressCell.h"

@class iStayHealthyRecord, Contacts;
@interface ClinicAddTableViewController : UITableViewController<ClinicAddressCellDelegate, UIAlertViewDelegate>{
@private
	iStayHealthyRecord *record;
    Contacts * contacts;    
    NSString *name;
    NSString *idString;
    NSString *www;
    NSString *email;
    NSString *number;
    NSString *emergencynumber;    
    BOOL isInChangeMode;
}
@property BOOL isInChangeMode;
@property (nonatomic, strong) iStayHealthyRecord *record;
@property (nonatomic, strong) Contacts *contacts;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *idString;
@property (nonatomic, strong) NSString *www;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *number;
@property (nonatomic, strong) NSString *emergencynumber;
- (IBAction) showAlertView:			(id) sender;
- (void)removeSQLEntry;
- (IBAction) saveNewEntry:			(id) sender;
- (IBAction) saveEditedEntry:       (id) sender;
- (IBAction) cancel:				(id) sender;
- (id)initWithRecord:(iStayHealthyRecord *)masterrecord;
- (id)initWithContacts:(Contacts *)_contacts WithRecord:(iStayHealthyRecord *)masterrecord;

@end
