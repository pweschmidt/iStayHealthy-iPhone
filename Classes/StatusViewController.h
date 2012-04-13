//
//  StatusViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 04/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iStayHealthyTableViewController.h"
#define TEXTCELLHEIGHT 30.0
#define CHARTCELLHEIGHT 208.0

@class StatusViewControllerLandscape;
@class HealthChartsView;
@class StatusViewCell;
@class ChartEvents;
@class Results;
//@class ChartView;

@interface StatusViewController : iStayHealthyTableViewController {
//	BOOL isShowingLandscapeView;
//	StatusViewControllerLandscape *landscapeController;
	NSMutableArray *allResults;
	NSMutableArray *allMeds;
    NSMutableArray *allMissedMeds;
	HealthChartsView *chartView;
    ChartEvents *events;
//    UIView *headerView;
//	ChartView *chartView;
	StatusViewCell *cd4StatusCell;
    StatusViewCell *cd4PercentCell;
	StatusViewCell *viralLoadStatusCell;
}
//@property (nonatomic, retain) ChartView *chartView;
@property (nonatomic, retain) HealthChartsView *chartView;
//@property (nonatomic, retain) StatusViewControllerLandscape *landscapeController;
@property (nonatomic, retain) StatusViewCell *cd4StatusCell;
@property (nonatomic, retain) StatusViewCell *cd4PercentCell;
@property (nonatomic, retain) StatusViewCell *viralLoadStatusCell;
@property (nonatomic, retain) NSMutableArray *allResults;
@property (nonatomic, retain) NSMutableArray *allMeds;
@property (nonatomic, retain) NSMutableArray *allMissedMeds;
@property (nonatomic, retain) ChartEvents *events;
//@property (nonatomic, retain) IBOutlet UIView *headerView;
- (void)configureCD4Cell;
- (void)configureCD4PercentCell;
- (void)configureViralLoadCell;
- (void) showInfoView:(id)sender;
- (void) showSettingsView:(id)sender;
- (Results *)latestResult:(NSString *)type;
- (Results *)previousResult:(NSString *)type;

@end
