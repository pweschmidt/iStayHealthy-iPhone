//
//  SideEffectsDetailsTableViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 03/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class iStayHealthyRecord, Medication;
@protocol SideEffectsDetailDelegate;

@interface SideEffectsDetailsTableViewController : UITableViewController
@property (nonatomic, weak) id<SideEffectsDetailDelegate>sideEffectsDelegate;
- (id)initWithMasterRecord:(iStayHealthyRecord *)masterRecord withMedication:(Medication *)medication;
@end

@protocol SideEffectsDetailDelegate <NSObject>

- (void)addSideEffect:(NSString *)effectName;
- (void)removeSideEffect:(NSString *)effectName;
- (void)setSeverity:(NSInteger) severityIndex;

@end