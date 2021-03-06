//
//  PWESIndicatorView.m
//  HealthCharts
//
//  Created by Peter Schmidt on 16/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import "PWESIndicatorView.h"
#import <QuartzCore/QuartzCore.h>

@interface PWESIndicatorView ()
@property (nonatomic, strong) PWESDataTuple *tuple;

@end

@implementation PWESIndicatorView

+ (PWESIndicatorView *)initWithFrame:(CGRect)frame
                               tupel:(PWESDataTuple *)tuple
{
    PWESIndicatorView *indicator = [[PWESIndicatorView alloc] initWithFrame:frame];

    [indicator buildIndicatorViewWithTuple:tuple];
    return indicator;
}

- (void)buildIndicatorViewWithTuple:(PWESDataTuple *)tuple
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    CGRect frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);

    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:13];
    label.textAlignment = NSTextAlignmentCenter;
    if (1 < tuple.valueTuple.count)
    {
        NSNumber *lastValue = [tuple.valueTuple lastObject];
        NSUInteger previousIndex = tuple.valueTuple.count - 2;
        NSNumber *previousValue = [tuple.valueTuple objectAtIndex:previousIndex];
        float difference = [lastValue floatValue] - [previousValue floatValue];
        label.text = [PWESIndicatorView valueStringForValue:difference
                                                       type:tuple.type
                                                hasPlusSign:YES];
        if ([label.text isEqualToString:NSLocalizedString(@"no change", nil)])
        {
            label.textColor = [UIColor darkGrayColor];
        }
        else
        {
            label.textColor = [self colourForDifference:difference type:tuple.type label:label];
        }
    }
    [self addSubview:label];
}

+ (NSString *)valueStringForValue:(float)value type:(NSString *)type hasPlusSign:(BOOL)hasPlusSign
{
    if (0 == value)
    {
        return NSLocalizedString(@"no change", nil);
    }
    BOOL isPlus = (0 < value && hasPlusSign) ? YES : NO;
    if ([type isEqualToString:kCD4] || [type isEqualToString:kHeartRate]
        || [type isEqualToString:kHepCViralLoad] || [type isEqualToString:kViralLoad] || [type isEqualToString:kSystole] || [type isEqualToString:kDiastole])
    {
        int iValue = (int) value;
        return (isPlus) ? [NSString stringWithFormat:@"%+d", iValue] : [NSString stringWithFormat:@"%d", iValue];
    }
    else
    {
        return (isPlus) ? [NSString stringWithFormat:@"%+3.2f", value] : [NSString stringWithFormat:@"%3.2f", value];
    }
}

- (UIColor *)colourForDifference:(float)difference type:(NSString *)type label:(UILabel *)label
{
    UIColor *evaluator = (0 > difference) ? DARK_RED : DARK_GREEN;
    UIColor *inverseEvaluator = (0 > difference) ? DARK_GREEN : DARK_RED;

    if ([type isEqualToString:kCD4]
        || [type isEqualToString:kCD4Percent])
    {
        label.textColor = [UIColor whiteColor];
        return evaluator;
    }
    else if ([type isEqualToString:kHepCViralLoad]
             || [type isEqualToString:kViralLoad]
             || [type isEqualToString:kCardiacRiskFactor]
             || [type isEqualToString:kTotalCholesterol]
             || [type isEqualToString:kHDL])
    {
        label.textColor = [UIColor whiteColor];
        return inverseEvaluator;
    }

    return [UIColor clearColor];
}

@end
