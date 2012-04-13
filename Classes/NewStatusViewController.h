//
//  NewStatusViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 29/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iStayHealthyTableViewController.h"
#define TEXTCELLHEIGHT 30.0
#define CHARTCELLHEIGHT 208.0

@class HealthChartsViewPortrait;
@class SummaryCell;
@class ChartEvents;
@class Results;

@interface NewStatusViewController : iStayHealthyTableViewController{
	HealthChartsViewPortrait *chartView;
    ChartEvents *events;
}
@property (nonatomic, retain) HealthChartsViewPortrait *chartView;
@property (nonatomic, retain) ChartEvents *events;
- (void)configureCD4Cell:(SummaryCell *)cell;
- (void)configureCD4PercentCell:(SummaryCell *)cell;
- (void)configureViralLoadCell:(SummaryCell *)cell;
- (void) showInfoView:(id)sender;
- (void) showSettingsView:(id)sender;
- (Results *)latestResult:(NSString *)type;
- (Results *)previousResult:(NSString *)type;

@end
