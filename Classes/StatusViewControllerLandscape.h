//
//  StatusViewControllerLandscape.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class ChartViewLandscape;
@class HealthChartsViewLandscape;
@class iStayHealthyRecord;
@class ChartEvents;

@interface StatusViewControllerLandscape : UIViewController <UIAlertViewDelegate, NSFetchedResultsControllerDelegate>{
	UIStatusBarStyle oldStatusBarStyle;
	HealthChartsViewLandscape *chartView;
	NSMutableArray *allResults;
	NSMutableArray *allMeds;
    NSMutableArray *allMissedMeds;
//	NSFetchedResultsController *fetchedResultsController_;
    BOOL hasNoResults;
    BOOL hasNoMedications;
    BOOL hasNoMissedDates;
	iStayHealthyRecord *masterRecord;
    ChartEvents *events;
}
@property (nonatomic, strong) HealthChartsViewLandscape *chartView;
@property (nonatomic, strong) NSMutableArray *allResults;
@property (nonatomic, strong) NSMutableArray *allMeds;
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) iStayHealthyRecord *masterRecord;
@property (nonatomic, strong) NSMutableArray *allMissedMeds;
@property (nonatomic, strong) ChartEvents *events;
- (void)reloadData:(NSNotification*)note;
- (void)setUpData;
@end
