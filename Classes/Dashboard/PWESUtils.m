//
//  PWESUtils.m
//  HealthCharts
//
//  Created by Peter Schmidt on 16/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import "PWESUtils.h"
#import "PWESChartsConstants.h"
#import "Constants.h"

@interface PWESUtils ()
@property (nonatomic, strong) NSDictionary *typeMap;
@end


@implementation PWESUtils
+ (id)sharedInstance
{
	static PWESUtils *utils = nil;
	static dispatch_once_t token;
	dispatch_once(&token, ^{
	    utils = [[PWESUtils alloc] init];
	});
	return utils;
}

- (id)init
{
	self = [super init];
	if (nil != self)
	{
		_typeMap = [self map];
	}
	return self;
}

- (NSString *)objectForType:(SingleResultType)type
{
	return [self.typeMap objectForKey:[NSNumber numberWithUnsignedInteger:type]];
}

- (EvaluationType)evaluationTypeForDifference:(float)difference
                                   resultType:(SingleResultType)resultType
{
	NSUInteger eval = NEUTRAL;
	if (0 < difference)
	{
		eval = GOOD;
	}
	else if (0 > difference)
	{
		eval = BAD;
	}
	if (resultType == ViralLoadType || resultType == HepCViralLoadType)
	{
		if (0 < difference)
		{
			eval = BAD;
		}
		else if (0 > difference)
		{
			eval = GOOD;
		}
	}
	return eval;
}

- (NSDictionary *)map
{
	NSDictionary *map = @{ [NSNumber numberWithUnsignedInteger:CD4Type]: kCD4,
		                   [NSNumber numberWithUnsignedInteger:CD4PercentType] : kCD4Percent,
		                   [NSNumber numberWithUnsignedInteger:ViralLoadType] : kViralLoad,
		                   [NSNumber numberWithUnsignedInteger:HepCViralLoadType] : kHepCViralLoad,
		                   [NSNumber numberWithUnsignedInteger:TotalCholesterolType] : kTotalCholesterol,
		                   [NSNumber numberWithUnsignedInteger:HDLType] : kHDL,
		                   [NSNumber numberWithUnsignedInteger:LDLType] : kLDL,
		                   [NSNumber numberWithUnsignedInteger:TriglycerideType] : kTriglyceride,
		                   [NSNumber numberWithUnsignedInteger:CardiacRisk] : kCardiacRiskFactor,
		                   [NSNumber numberWithUnsignedInteger:CholesterolRatioType] : kCholesterolRatio,
		                   [NSNumber numberWithUnsignedInteger:WeightType] : kWeight,
		                   [NSNumber numberWithUnsignedInteger:SystoleType] : kSystole,
		                   [NSNumber numberWithUnsignedInteger:DiastoleType] : kDiastole,
		                   [NSNumber numberWithUnsignedInteger:HeartRateType] : kHeartRate,
		                   [NSNumber numberWithUnsignedInteger:Glucose] : kGlucose };
	return map;
}

- (void)drawLineWithContext:(CGContextRef)context
                      start:(CGPoint)start
                        end:(CGPoint)end
                  lineWidth:(CGFloat)lineWidth
                   cgColour:(CGColorRef)cgColour
{
	CGContextSaveGState(context);
	CGContextSetLineCap(context, kCGLineCapSquare);
	CGContextSetStrokeColorWithColor(context, cgColour);
	CGContextSetLineWidth(context, lineWidth);
	CGFloat lineOffset = lineWidth / 2;
	CGContextMoveToPoint(context, start.x + lineOffset, start.y + lineOffset);
	CGContextAddLineToPoint(context, end.x + lineOffset, end.y + lineOffset);
	CGContextStrokePath(context);
	CGContextRestoreGState(context);
}

@end
