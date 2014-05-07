//
//  PWESMonthlyView.h
//  SeinfeldCalendarWithLayers
//
//  Created by Peter Schmidt on 23/04/2014.
//  Copyright (c) 2014 Peter Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PWESSeinfeldMonth;
@protocol PWESResultsDelegate;

@interface PWESMonthlyView : UIView <UIAlertViewDelegate>
@property (nonatomic, weak) id <PWESResultsDelegate> resultsDelegate;
+ (PWESMonthlyView *)monthlyViewWithFrame:(CGRect)monthlyFrame
                            seinfeldMonth:(PWESSeinfeldMonth *)seinfeldMonth;
@end
