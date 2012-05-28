//
//  MissedMedViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 19/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iStayHealthyRecord;
@interface MissedMedViewController : UITableViewController{
	iStayHealthyRecord *record;    
    NSMutableArray *missedMeds;
}
@property (nonatomic, strong) iStayHealthyRecord *record;
@property (nonatomic, strong) NSMutableArray *missedMeds;
- (IBAction) done:					(id) sender;
- (id)initWithRecord:(iStayHealthyRecord *)masterrecord;
- (NSString *)getStringFromName:(NSString *)name;
@end
