//
//  StatusViewControllerLandscape.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HealthChartsViewLandscape;
@class ChartEvents;

@interface StatusViewControllerLandscape : UIViewController <UIAlertViewDelegate>
- (void)reloadData:(NSNotification*)note;
- (void)start;
@end
