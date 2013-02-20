//
//  NewStatusViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 29/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicViewController.h"

#define TEXTCELLHEIGHT 30.0
#define CHARTCELLHEIGHT 208.0

@class HealthChartsViewPortrait;
@class SummaryCell;
@class ChartEvents;
@class Results;

@interface NewStatusViewController : BasicViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) HealthChartsViewPortrait *chartView;
@property (nonatomic, strong) ChartEvents *events;
@property (nonatomic, strong) NSNumber * sizeOfSummaryCell;
@property (nonatomic, strong) NSNumber * sizeOfChartCell;
- (void)configureCD4Cell:(SummaryCell *)cell;
- (void)configureCD4PercentCell:(SummaryCell *)cell;
- (void)configureViralLoadCell:(SummaryCell *)cell;
- (void) showInfoView:(id)sender;
- (void) showSettingsView:(id)sender;
@end
