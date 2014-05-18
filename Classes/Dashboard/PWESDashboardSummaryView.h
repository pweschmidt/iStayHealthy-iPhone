//
//  PWESDashboardSummaryView.h
//  HealthCharts
//
//  Created by Peter Schmidt on 20/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PWESDataNTuple.h"

@interface PWESDashboardSummaryView : UIView
+ (PWESDashboardSummaryView *)summaryViewWithFrame:(CGRect)frame
                                            nTuple:(PWESDataNTuple *)nTuple
                                             types:(NSArray *)types;
@end
