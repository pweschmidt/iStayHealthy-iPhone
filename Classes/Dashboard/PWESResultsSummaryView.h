//
//  PWESResultsSummaryView.h
//  HealthCharts
//
//  Created by Peter Schmidt on 20/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PWESDataTuple.h"

@interface PWESResultsSummaryView : UIView

+ (PWESResultsSummaryView *)resultsSummaryViewWithFrame:(CGRect)frame
                                              dataTuple:(PWESDataTuple *)dataTuple
                                            medications:(NSArray *)medications;


@end
