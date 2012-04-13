//
//  AppointmentPlannerViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 23/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class iStayHealthyRecord;

@interface AppointmentPlannerViewController : UITableViewController{
   
    iStayHealthyRecord *record;
    NSArray *meds;
}
@property (nonatomic, retain) iStayHealthyRecord *record;
@property (nonatomic, retain) NSArray *meds;
- (id)initWithRecord:(iStayHealthyRecord *)masterRecord;
- (IBAction) save:					(id) sender;
- (IBAction) cancel:				(id) sender;
@end
