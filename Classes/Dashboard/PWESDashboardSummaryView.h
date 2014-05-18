//
//  PWESDashboardSummaryView.h
//  HealthCharts
//
//  Created by Peter Schmidt on 20/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PWESDataNTuple.h"
#import "PWESResultsTypes.h"

@interface PWESDashboardSummaryView : UIView
/**
   creates a summary view
   @param frame
   @param nTuple
   @param types
 */
+ (PWESDashboardSummaryView *)summaryViewWithFrame:(CGRect)frame
                                            nTuple:(PWESDataNTuple *)nTuple
                                             types:(PWESResultsTypes *)types;
@end
