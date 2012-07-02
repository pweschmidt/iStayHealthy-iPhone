//
//  SideEffectsViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 19/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideEffectDetailViewController.h"
@class iStayHealthyRecord;
@interface SideEffectsViewController : UITableViewController <SideEffectUpdateDelegate>
@property (nonatomic, strong) iStayHealthyRecord *record;
@property (nonatomic, strong) NSMutableArray *sideeffects;
- (IBAction) done:					(id) sender;
- (id)initWithRecord:(iStayHealthyRecord *)masterrecord;

@end
