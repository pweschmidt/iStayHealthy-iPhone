//
//  SideEffectsViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 19/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iStayHealthyTableViewController.h"
#import "SideEffectDetailViewController.h"
@class iStayHealthyRecord;
@interface SideEffectsViewController : iStayHealthyTableViewController <SideEffectUpdateDelegate>
- (IBAction) done:					(id) sender;

@end
