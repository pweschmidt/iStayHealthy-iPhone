//
//  ClinicTableViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 09/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iStayHealthyTableViewController.h"
@class iStayHealthyRecord, Contacts;
@interface ClinicTableViewController : iStayHealthyTableViewController<UIActionSheetDelegate>{
    NSMutableArray *contacts;
    int selectedRow;
}
@property (nonatomic, retain) NSMutableArray *contacts;
- (IBAction) done:				(id) sender;
- (void) showActionSheetForContact:(Contacts *)contact;
- (void)loadClinicAddViewController;
- (void)loadClinicChangeViewController;
@end
