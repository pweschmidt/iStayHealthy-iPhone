//
//  SideEffectDetailViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 27/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class iStayHealthyRecord, SideEffects;
@protocol SideEffectUpdateDelegate;

@interface SideEffectDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *sideEffectTableView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *seriousnessControl;
@property (nonatomic, weak) IBOutlet UIButton *dateButton;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *selectedSideEffectLabel;
@property (nonatomic, weak) id<SideEffectUpdateDelegate>sideEffectDelegate;
- (IBAction)seriousnessChanged:(id)sender;
- (IBAction)setDate:(id)sender;
- (id)initWithRecord:(iStayHealthyRecord *)record effectDelegate:(id)effectDelegate;
- (id)initWithRecord:(iStayHealthyRecord *)record sideEffects:(SideEffects *)effects effectDelegate:(id)effectDelegate;
@end

@protocol SideEffectUpdateDelegate <NSObject>
- (void)updateSideEffectTable;
@end
