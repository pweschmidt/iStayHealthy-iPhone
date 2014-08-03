//
//  PWESPlotView.m
//  HealthCharts
//
//  Created by Peter Schmidt on 13/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import "PWESPlotView.h"
#import "PWESVerticalAxis.h"
#import "PWESHorizontalAxis.h"
#import "PWESChartsConstants.h"
#import "PWESValueRange.h"
#import "PWESPlotArea.h"
#import "PWESMedPlotArea.h"
#import "PWESResultDatesPlotArea.h"
#import "UIFont+Standard.h"
#import "Utilities.h"
#import "PWESLabelPlotArea.h"
#import <QuartzCore/QuartzCore.h>

static NSDictionary *defaultiPadAxisAttributes()
{
	NSDictionary *attributes = @{ kPlotAxisTitleFontSize : [NSNumber numberWithFloat:standard],
		                          kPlotAxisTickLabelFontSize : [NSNumber numberWithFloat:tiny],
		                          kPlotAxisTitleFontName : kDefaultLightFont,
		                          kPlotAxisTickFontName : kDefaultBoldFont,
		                          kPlotAxisTickLabelExpFontSize : [NSNumber numberWithFloat:veryTiny] };
	return attributes;
}

@interface PWESPlotView ()
{
	CGRect plotBoundaries;
	CGRect yAxisFrame;
	CGRect yAxisFrameRight;
	CGRect xAxisFrame;
//	CGRect xAxisFrameTop;
	CGRect plotAreaFrame;
	CGRect dateLabelFrame;
	CGFloat ticks;
	CGFloat logTicks;
	CGFloat logTickDistance;
}
@property (nonatomic, strong) PWESAxis *xAxis;
@property (nonatomic, strong) PWESAxis *yAxis;
@property (nonatomic, strong) PWESAxis *yAxisRight;
@property (nonatomic, strong) PWESAxis *xAxisTop;
@property (nonatomic, strong) PWESPlotArea *plotArea;
@property (nonatomic, strong) PWESPlotArea *secondPlotArea;
@property (nonatomic, strong) PWESMedPlotArea *medPlotArea;
@property (nonatomic, strong) PWESResultDatesPlotArea *datesArea;
@property (nonatomic, strong) PWESResultsTypes *types;
@property (nonatomic, strong) PWESDataNTuple *ntuple;
@property (nonatomic, strong) PWESDataTuple *firstTuple;
@property (nonatomic, strong) PWESDataTuple *secondTuple;
@end

@implementation PWESPlotView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		_marginBottom = _marginTop = 20;
		_marginLeft = _marginRight = 35;
		logTicks = kMaxLog10Ticks;
	}
	return self;
}

+ (PWESPlotView *)plotViewWithFrame:(CGRect)frame
                             nTuple:(PWESDataNTuple *)nTuple
                              types:(PWESResultsTypes *)types
{
	return [PWESPlotView plotViewWithFrame:frame nTuple:nTuple types:types pxTickDistance:kPXTickDistance];
}

+ (PWESPlotView *)plotViewWithFrame:(CGRect)frame
                             nTuple:(PWESDataNTuple *)nTuple
                              types:(PWESResultsTypes *)types
                     pxTickDistance:(CGFloat)pxTickDistance
{
	PWESPlotView *plotView = [[PWESPlotView alloc] initWithFrame:frame];
	plotView.pxTickDistance = pxTickDistance;
	plotView.ntuple = nTuple;
	plotView.types = types;
	plotView.axisAttributes = [NSMutableDictionary dictionaryWithDictionary:defaultiPadAxisAttributes()];

	[plotView show];
	return plotView;
}

#pragma mark private methods
- (void)show
{
	if (self.ntuple.isEmpty || ![self.ntuple hasResults])
	{
		UILabel *emptyLabel = [self emptyLabelView];
		[self addSubview:emptyLabel];
		return;
	}
	[self createFramesAndOffsets];

	PWESDataTuple *firstTuple = [self.ntuple resultsTupleForType:self.types.mainType];
	self.firstTuple = firstTuple;

	PWESVerticalAxis *yAxis = [self leftYAxisResultsTuple:firstTuple];
	[self showAxis:yAxis];
	self.yAxis = yAxis;

	PWESHorizontalAxis *xAxis = [self bottomAxis];
	[self showAxis:xAxis];
	self.xAxis = xAxis;

	self.plotArea = [self plotAreaForType:self.types.mainType];

	if (self.plotArea)
	{
		[self.layer addSublayer:self.plotArea.plotLayer];
		[self.plotArea plotDataTuple:self.firstTuple];
	}

	if (self.types.isDualType)
	{
		PWESDataTuple *secondTuple = [self.ntuple resultsTupleForType:self.types.secondaryType];
		self.secondTuple = secondTuple;

		PWESVerticalAxis *yAxisRight = [self rightYAxisResultsTuple:secondTuple type:self.types.secondaryType];
		[self showAxis:yAxisRight];
		self.yAxisRight = yAxisRight;

		if ([self.types.secondaryType isEqualToString:kViralLoad])
		{
			ticks = logTicks;
		}

		self.secondPlotArea = [self plotAreaForType:self.types.secondaryType];
		if (self.secondPlotArea)
		{
			[self.layer addSublayer:self.secondPlotArea.plotLayer];
			[self.secondPlotArea plotDataTuple:self.secondTuple];
		}
	}

	[self showMedLine];
	[self showResultsDates];
}

- (void)showMedLine
{
	if (self.types.showMedLine)
	{
		PWESMedPlotArea *medArea = [[PWESMedPlotArea alloc] initWithFrame:plotAreaFrame
		                                                        marginTop:self.marginTop
		                                                         dateLine:self.ntuple.dateLine];
		if (nil != medArea)
		{
			self.medPlotArea = medArea;
			PWESDataTuple *medTuple = [self.ntuple medicationTuple];
			[self.layer addSublayer:self.medPlotArea.plotLayer];
			[self.medPlotArea plotMedicationTuple:medTuple];
		}
	}
}

- (void)showResultsDates
{
	PWESResultDatesPlotArea *datesArea = [[PWESResultDatesPlotArea alloc] initWithFrame:dateLabelFrame
	                                                                       marginBottom:self.marginBottom
	                                                                             ntuple:self.ntuple];
	self.datesArea = datesArea;
	[self.layer addSublayer:self.datesArea.plotLayer];
	[self.datesArea plotDates];
}

- (UILabel *)emptyLabelView
{
	UILabel *emptyLabel = [[UILabel alloc] init];
	emptyLabel.frame = CGRectMake(self.bounds.origin.x + self.bounds.size.width / 2 - 100, self.bounds.origin.y + self.bounds.size.height / 2 - 50, 200, 100);
	emptyLabel.backgroundColor = [UIColor clearColor];
	emptyLabel.textAlignment = NSTextAlignmentCenter;
	emptyLabel.textColor = TEXTCOLOUR;
	emptyLabel.numberOfLines = 0;
	emptyLabel.lineBreakMode = NSLineBreakByWordWrapping;
	emptyLabel.font = [UIFont fontWithType:Light size:20];
	emptyLabel.text = NSLocalizedString(@"No results available", nil);
	return emptyLabel;
}

- (void)createFramesAndOffsets
{
	yAxisFrame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.marginLeft * 2, self.bounds.size.height - self.marginBottom);
	yAxisFrameRight = CGRectMake(self.bounds.origin.x + self.bounds.size.width - self.marginRight - self.marginLeft - 3, self.bounds.origin.y, self.marginLeft * 2, self.bounds.size.height - self.marginBottom);
	xAxisFrame = CGRectMake(self.bounds.origin.x + self.marginLeft, self.bounds.size.height - self.marginBottom - self.marginTop, self.bounds.size.width - self.marginRight - self.marginLeft, self.marginBottom * 2);
//	xAxisFrameTop = CGRectMake(self.bounds.origin.x + self.marginLeft, self.bounds.origin.y - self.marginTop, self.bounds.size.width - self.marginRight - self.marginLeft, self.marginBottom * 2);

	plotAreaFrame = CGRectMake(self.bounds.origin.x + self.marginLeft, self.bounds.origin.y, self.bounds.size.width - self.marginRight - self.marginLeft, self.bounds.size.height - self.marginBottom);

	dateLabelFrame = CGRectMake(self.bounds.origin.x + self.marginLeft, self.bounds.origin.y, self.bounds.size.width - self.marginRight - self.marginLeft, self.bounds.size.height);


	ticks = roundf(yAxisFrame.size.height / self.pxTickDistance);
	CGFloat logHeight = ticks * self.pxTickDistance;
	logTickDistance = roundf(logHeight / kMaxLog10Ticks);
}

- (PWESVerticalAxis *)leftYAxisResultsTuple:(PWESDataTuple *)resultsTuple
{
	NSString *axisType = self.types.mainType;
	UIColor *lineColour = [self colourForType:axisType];
	PWESValueRange *range = [PWESValueRange valueRangeForDataTuple:resultsTuple ticks:ticks];


	PWESVerticalAxis *yAxis = [[PWESVerticalAxis alloc] initVerticalAxisWithFrame:yAxisFrame
	                                                                   valueRange:range
	                                                                  orientation:Vertical
	                                                                        ticks:ticks];
	yAxis.axisTitle = axisType;
	yAxis.titleColor = lineColour;
	yAxis.tickLabelOffsetX = 5;
	if ([axisType isEqualToString:kCD4] || [axisType isEqualToString:kCD4Percent])
	{
		yAxis.showAxisLabel = YES;
	}
	return yAxis;
}

- (PWESVerticalAxis *)rightYAxisResultsTuple:(PWESDataTuple *)resultsTuple type:(NSString *)type
{
	if (self.types.isDualType)
	{
		NSString *axisType = self.types.secondaryType;
		UIColor *lineColour = [self colourForType:axisType];
		BOOL isLogAxis = ([type isEqualToString:kViralLoad] || [type isEqualToString:kHepCViralLoad]);
		CGFloat ticksToUse = (isLogAxis) ? kMaxLog10Ticks : ticks;
		PWESValueRange *range = [PWESValueRange valueRangeForDataTuple:resultsTuple ticks:ticksToUse];
		PWESVerticalAxis *yAxis = nil;
		if (isLogAxis)
		{
			yAxis = [[PWESVerticalAxis alloc] initVerticalLogAxisWithFrame:yAxisFrameRight
			                                                    valueRange:range orientation:VerticalRight
			                                               logTickDistance:logTickDistance];
			yAxis.axisTitle = axisType;
			yAxis.titleColor = lineColour;
			yAxis.showAxisLabel = YES;
		}
		else
		{
			yAxis = [[PWESVerticalAxis alloc] initVerticalAxisWithFrame:yAxisFrameRight
			                                                 valueRange:range
			                                                orientation:VerticalRight
			                                                      ticks:ticksToUse];
		}
		yAxis.axisTitle = axisType;
		yAxis.titleColor = lineColour;
		yAxis.tickLabelOffsetX = 2;
		return yAxis;
	}
	else
	{
		return [[PWESVerticalAxis alloc] initVerticalAxisWithFrame:yAxisFrameRight
		                                               orientation:VerticalRight];
	}
}

- (PWESHorizontalAxis *)bottomAxis
{
	PWESHorizontalAxis *bottomAxis = [[PWESHorizontalAxis alloc]
	                                  initHorizontalAxisWithFrame:xAxisFrame
	                                                  orientation:Horizontal
	                                                   attributes:nil
	                                                       ntuple:self.ntuple
	                                                 showAtBottom:YES];
	return bottomAxis;
}

//- (PWESHorizontalAxis *)topAxis
//{
//	PWESHorizontalAxis *xTopAxis = [[PWESHorizontalAxis alloc] initHorizontalAxisWithFrame:xAxisFrameTop];
//	return xTopAxis;
//}

- (PWESValueRange *)valueRangeForType:(NSString *)type tickCounts:(CGFloat)tickCounts
{
	PWESValueRange *valueRange = nil;
	PWESDataTuple *tuple = [self.ntuple resultsTupleForType:type];
	if (nil != tuple)
	{
		valueRange = [PWESValueRange valueRangeForDataTuple:tuple ticks:tickCounts];
	}
	return valueRange;
}

- (void)showAxis:(PWESAxis *)axis
{
	if (nil != axis && nil != axis.axisLayer)
	{
		[self.layer addSublayer:axis.axisLayer];
		[axis show];
	}
}

- (PWESPlotArea *)plotAreaForType:(NSString *)type
{
	BOOL isLog = ([type isEqualToString:kViralLoad] || [type isEqualToString:kHepCViralLoad]);
	CGFloat ticksToUse = (isLog) ? kMaxLog10Ticks : ticks;
	CGFloat tickDistanceToUse = (isLog) ? logTickDistance : self.pxTickDistance;

	PWESValueRange *range = [self valueRangeForType:type tickCounts:ticksToUse];
	UIColor *colour = [self colourForType:type];
	PWESPlotArea *area = [[PWESPlotArea alloc] initWithFrame:plotAreaFrame
	                                              lineColour:colour
	                                              valueRange:range
	                                                dateLine:self.ntuple.dateLine
	                                            tickDistance:tickDistanceToUse];
	return area;
}

- (UIColor *)colourForType:(NSString *)type
{
	if ([type isEqualToString:kCD4] || [type isEqualToString:kCD4Percent])
	{
		return DARK_YELLOW;
	}
	else if ([type isEqualToString:kViralLoad] || [type isEqualToString:kHepCViralLoad])
	{
		return DARK_BLUE;
	}
	else if ([type isEqualToString:kCardiacRiskFactor] || [type isEqualToString:kSystole] || [type isEqualToString:kDiastole] || [type isEqualToString:kWeight] || [type isEqualToString:kBMI])
	{
		return DARK_GREEN;
	}
	return DARK_RED;
}

@end
