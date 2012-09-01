//
//  MissedMedViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 19/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iStayHealthyTableViewController.h"

@class iStayHealthyRecord;
@interface MissedMedViewController : iStayHealthyTableViewController
- (IBAction) done:					(id) sender;
- (NSString *)getStringFromName:(NSString *)name;
@end
