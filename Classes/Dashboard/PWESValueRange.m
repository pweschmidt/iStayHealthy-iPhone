//
//  PWESValueRange.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 23/11/2013.
//
//

#import "PWESValueRange.h"
#import "PWESDataTuple.h"
#import "NSArray+Extras.h"
#import "Constants.h"

@interface PWESValueRange ()
@property (nonatomic, strong, readwrite) NSNumber *minValue;
@property (nonatomic, strong, readwrite) NSNumber *maxValue;
@property (nonatomic, assign, readwrite) CGFloat tickDeltaValue;
@property (nonatomic, strong, readwrite) NSString *type;
@end

@implementation PWESValueRange

+ (PWESValueRange *)valueRangeForDataTuple:(PWESDataTuple *)tuple
                                     ticks:(CGFloat)ticks
{
    PWESValueRange *range = [[PWESValueRange alloc] init];
    if (nil == tuple)
    {
        range.type = kNoResult;
        range.maxValue = [NSNumber numberWithFloat:-1];
        range.minValue = [NSNumber numberWithFloat:-1];
        return range;
    }
    range.type = tuple.type;
    range.maxValue = [tuple.valueTuple maxNumber];
    range.minValue = [tuple.valueTuple minNumber];
    if (![range.type isEqualToString:kViralLoad] && ![range.type isEqualToString:kHepCViralLoad])
    {
        [range correctForTicks:ticks];
    }
    return range;
}

- (void)correctForTicks:(CGFloat)ticks
{
    if (0 > [self.maxValue floatValue] || 0 > [self.minValue floatValue])
    {
        return;
    }
    
    float maxD = floorf([self.maxValue floatValue] * 1.5);
    float minD = floorf([self.minValue floatValue] / 1.5);
    if (0 > minD) {
        minD = 0;
    }
    CGFloat tickDistance = (maxD - minD) / ticks;
    float multiplier = 1;
    
    if (10 >= maxD)//2 point decimals
    {
        multiplier = 100;
    }
    else if (100 >= maxD)//1 point decimal
    {
        multiplier = 10;
    }
    
    float distD = floorf(tickDistance * multiplier);
    distD = floorf(distD / 5);
    tickDistance = (distD * 5) / multiplier;
    float nextMin = 0;
    float previousMin = 0;
    for (int tick = 0; tick < ticks; ++tick)
    {
        nextMin = tick * tickDistance;
        if (minD >= previousMin && minD <= nextMin) {
            minD = previousMin;
        }
        previousMin = nextMin;
    }
    maxD = minD + ticks * tickDistance;
    
    self.maxValue = [NSNumber numberWithFloat:maxD];
    self.minValue = [NSNumber numberWithFloat:minD];
    self.tickDeltaValue = tickDistance;
}

@end
