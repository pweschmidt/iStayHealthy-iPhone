//
//  NewContactTableViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 15/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class iStayHealthyRecord;
@interface NewContactTableViewController : UITableViewController{
@private
	NSDate *nextAppointmentDate;
	iStayHealthyRecord *record;
    
}
@property (nonatomic, retain) NSDate *nextAppointmentDate;
@property (nonatomic, retain) iStayHealthyRecord *record;
- (IBAction) save:					(id) sender;
- (IBAction) cancel:				(id) sender;
- (id)initWithRecord:(iStayHealthyRecord *)masterrecord;
@end
