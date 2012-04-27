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
@property (nonatomic, retain) HealthChartsViewLandscape *chartView;
@property (nonatomic, retain) NSMutableArray *allResults;
@property (nonatomic, retain) NSMutableArray *allMeds;
@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) iStayHealthyRecord *masterRecord;
@property (nonatomic, retain) NSMutableArray *allMissedMeds;
@property (nonatomic, retain) ChartEvents *events;
- (void)reloadData:(NSNotification*)note;
- (void)setUpData;
@end
