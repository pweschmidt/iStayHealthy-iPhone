//
//  ProcedureTableViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 19/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iStayHealthyTableViewController.h"
@class iStayHealthyRecord;
@interface ProcedureTableViewController : iStayHealthyTableViewController{
    NSMutableArray *procedures;
}
@property (nonatomic, retain) NSMutableArray *procedures;
- (IBAction) done:				(id) sender;
- (void)loadProcedureAddViewController;
- (void)loadProcedureChangeViewController:(int)row;

@end
