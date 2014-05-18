//
//  PWESPlotView.h
//  HealthCharts
//
//  Created by Peter Schmidt on 13/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PWESChartsConstants.h"
#import "PWESDataNTuple.h"
#import "PWESResultsTypes.h"

@interface PWESPlotView : UIView
@property (nonatomic, assign) CGFloat marginLeft;
@property (nonatomic, assign) CGFloat marginRight;
@property (nonatomic, assign) CGFloat marginTop;
@property (nonatomic, assign) CGFloat marginBottom;
@property (nonatomic, assign) CGFloat pxTickDistance;

/**
   Creates a plot view with axis and plot area for a given set of types
   @param frame
   @param nTuple
   @param types
   @return an instance of PWESPlotView
 */
+ (PWESPlotView *)plotViewWithFrame:(CGRect)frame
                             nTuple:(PWESDataNTuple *)nTuple
                              types:(PWESResultsTypes *)types;

@end
