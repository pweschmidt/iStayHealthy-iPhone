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
	iStayHealthyRecord *__unsafe_unretained record;    
    NSMutableArray *sideeffects;
}
@property (nonatomic, unsafe_unretained) iStayHealthyRecord *record;
@property (nonatomic, strong) NSMutableArray *sideeffects;
- (IBAction) done:					(id) sender;
- (id)initWithRecord:(iStayHealthyRecord *)masterrecord;

@end
