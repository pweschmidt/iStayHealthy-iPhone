//
//  PWESMonthlyView.h
//  SeinfeldCalendarWithLayers
//
//  Created by Peter Schmidt on 23/04/2014.
//  Copyright (c) 2014 Peter Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PWESSeinfeldMonth, SeinfeldCalendar;
@protocol PWESResultsDelegate;

@interface PWESMonthlyView : UIView
@property (nonatomic, weak) id <PWESResultsDelegate> resultsDelegate;

+ (PWESMonthlyView *)monthlyViewForCalendar:(SeinfeldCalendar *)calendar
                              seinfeldMonth:(PWESSeinfeldMonth *)seinfeldMonth
                                      frame:(CGRect)frame;
@end
