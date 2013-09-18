//
//  PWESIndicatorView.h
//  HealthCharts
//
//  Created by Peter Schmidt on 16/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PWESDataTuple.h"

@interface PWESIndicatorView : UIView
+ (PWESIndicatorView *)initWithFrame:(CGRect)frame
                               tupel:(PWESDataTuple *)tuple;
+ (NSString *)valueStringForValue:(float)value type:(NSString *)type hasPlusSign:(BOOL)hasPlusSign;
@end
