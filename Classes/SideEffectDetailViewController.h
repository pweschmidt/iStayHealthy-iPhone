//
//  SideEffectDetailViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 27/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideEffectDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *sideEffectTableView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *seriousnessControl;
@property (nonatomic, weak) IBOutlet UIButton *dateButton;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
- (IBAction)seriousnessChanged:(id)sender;
- (IBAction)setDate:(id)sender;
@end
