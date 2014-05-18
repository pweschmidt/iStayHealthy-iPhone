//
//  PWESDashboardView.h
//  HealthCharts
//
//  Created by Peter Schmidt on 20/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PWESChartsConstants.h"
#import "PWESDataNTuple.h"

@interface PWESDashboardView : UIView
/**
   builds the view based on the result types to be displayed. The view is split into 2 subviews
   a.) the summary containing text showing the latest results
   b.) the plot area below
   @param frame
   @param dataTuple the data tuple to be shown
   @param types an array of NSString data types to be shown
 */
+ (PWESDashboardView *)dashboardViewWithFrame:(CGRect)frame
                                       nTuple:(PWESDataNTuple *)nTuple
                                        types:(NSArray *)types;
@end
