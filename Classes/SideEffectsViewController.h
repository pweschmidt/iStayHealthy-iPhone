//
//  SideEffectsViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 19/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class iStayHealthyRecord;
@interface SideEffectsViewController : UITableViewController{
	iStayHealthyRecord *record;    
    NSMutableArray *sideeffects;
}
@property (nonatomic, assign) iStayHealthyRecord *record;
@property (nonatomic, retain) NSMutableArray *sideeffects;
- (IBAction) done:					(id) sender;
- (id)initWithRecord:(iStayHealthyRecord *)masterrecord;

@end
