//
//  PWESUtils.h
//  HealthCharts
//
//  Created by Peter Schmidt on 16/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PWESChartsConstants.h"

@interface PWESUtils : NSObject
+ (id)sharedInstance;

- (NSString *)objectForType:(SingleResultType)type;
- (EvaluationType)evaluationTypeForDifference:(float)difference
                                   resultType:(SingleResultType)resultType;

- (void)drawLineWithContext:(CGContextRef)context
                      start:(CGPoint)start
                        end:(CGPoint)end
                  lineWidth:(CGFloat)lineWidth
                   cgColour:(CGColorRef)cgColour;

@end
