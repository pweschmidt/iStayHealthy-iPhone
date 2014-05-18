//
//  PWESPlotView.m
//  HealthCharts
//
//  Created by Peter Schmidt on 13/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import "PWESPlotView.h"
#import "PWESAxis.h"
#import "PWESChartsConstants.h"
#import "PWESValueRange.h"
#import "PWESPlotArea.h"
#import "PWESMedPlotArea.h"
#import "UIFont+Standard.h"
#import <QuartzCore/QuartzCore.h>

@interface PWESPlotView ()
{
	CGRect plotBoundaries;
	CGRect yAxisFrame;
	CGRect yAxisFrameRight;
	CGRect xAxisFrame;
	CGRect xAxisFrameTop;
	CGRect plotAreaFrame;
	CGFloat ticks;
	CGFloat logTicks;
}
@property (nonatomic, strong) PWESAxis *xAxis;
@property (nonatomic, strong) PWESAxis *yAxis;
@property (nonatomic, strong) PWESAxis *yAxisRight;
@property (nonatomic, strong) PWESAxis *xAxisTop;
@property (nonatomic, strong) PWESPlotArea *plotArea;
@property (nonatomic, strong) PWESPlotArea *secondPlotArea;
@property (nonatomic, strong) PWESMedPlotArea *medPlotArea;
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
		_marginLeft = _marginRight = 20;
		logTicks = 11;
	}
	return self;
}

+ (PWESPlotView *)plotViewWithFrame:(CGRect)frame
                             nTuple:(PWESDataNTuple *)nTuple
                              types:(PWESResultsTypes *)types
{
	PWESPlotView *plotView = [[PWESPlotView alloc] initWithFrame:frame];
	plotView.pxTickDistance = kPXTickDistance;
	plotView.ntuple = nTuple;
	plotView.types = types;
	[plotView show];
	return plotView;
}

#pragma mark private methods
- (void)show
{
	if (self.ntuple.isEmpty)
	{
		UILabel *emptyLabel = [self emptyLabelView];
		[self addSubview:emptyLabel];
		return;
	}
	[self createFrames];

	ticks = roundf(yAxisFrame.size.height / self.pxTickDistance);
	PWESDataTuple *firstTuple = [self.ntuple resultsTupleForType:self.types.mainType];
	self.firstTuple = firstTuple;

	PWESAxis *yAxis = [self leftYAxisResultsTuple:firstTuple];
	[self showAxis:yAxis];
	self.yAxis = yAxis;

	PWESAxis *xAxis = [self xAxis];
	[self showAxis:xAxis];
	self.xAxis = xAxis;

	PWESAxis *xAxisTop = [self xAxisTop];
	[self showAxis:xAxisTop];
	self.xAxisTop = xAxisTop;

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

		PWESAxis *yAxisRight = [self rightYAxisResultsTuple:secondTuple type:self.types.secondaryType];
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
	else
	{
		PWESAxis *yAxisRight = [self rightYAxisResultsTuple:nil type:nil];
		[self showAxis:yAxisRight];
		self.yAxisRight = yAxisRight;
	}

	if (self.types.showMedLine)
	{
		PWESMedPlotArea *medArea = [[PWESMedPlotArea alloc] initWithFrame:plotAreaFrame dateLine:self.ntuple.dateLine];
		if (nil != medArea)
		{
			self.medPlotArea = medArea;
			PWESDataTuple *medTuple = [self.ntuple medicationTuple];
			[self.layer addSublayer:self.medPlotArea.plotLayer];
			[self.medPlotArea plotMedicationTuple:medTuple];
		}
	}
}

- (UILabel *)emptyLabelView
{
	UILabel *emptyLabel = [[UILabel alloc] init];
	emptyLabel.frame = CGRectMake(self.bounds.origin.x + self.bounds.size.width / 2 - 100, self.bounds.origin.y + self.bounds.size.height / 2 - 50, 200, 100);
	emptyLabel.backgroundColor = [UIColor clearColor];
	emptyLabel.textAlignment = NSTextAlignmentCenter;
	emptyLabel.textColor = TEXTCOLOUR;
	emptyLabel.font = [UIFont fontWithType:Light size:20];
	emptyLabel.text = NSLocalizedString(@"No results available", nil);
	return emptyLabel;
}

- (void)createFrames
{
	yAxisFrame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.marginLeft * 2, self.bounds.size.height - self.marginBottom);
	yAxisFrameRight = CGRectMake(self.bounds.origin.x + self.bounds.size.width - self.marginRight - self.marginLeft - 3, self.bounds.origin.y, self.marginLeft * 2, self.bounds.size.height - self.marginBottom);
	xAxisFrame = CGRectMake(self.bounds.origin.x + self.marginLeft, self.bounds.size.height - self.marginBottom - self.marginTop, self.bounds.size.width - self.marginRight - self.marginLeft, self.marginBottom * 2);
	xAxisFrameTop = CGRectMake(self.bounds.origin.x + self.marginLeft, 0 - self.marginTop, self.bounds.size.width - self.marginRight - self.marginLeft, self.marginBottom * 2);
	plotAreaFrame = CGRectMake(self.bounds.origin.x + self.marginLeft, self.bounds.origin.y, self.bounds.size.width - self.marginRight - self.marginLeft, self.bounds.size.height - self.marginBottom);
}

- (PWESAxis *)leftYAxisResultsTuple:(PWESDataTuple *)resultsTuple
{
	NSString *axisType = self.types.mainType;
	UIColor *lineColour = [self colourForType:axisType];
	PWESValueRange *range = [PWESValueRange valueRangeForDataTuple:resultsTuple ticks:ticks];


	PWESAxis *yAxis = [[PWESAxis alloc] initVerticalAxisWithFrame:yAxisFrame
	                                                   valueRange:range
	                                                  orientation:Vertical
	                                                        ticks:ticks];
	yAxis.axisTitle = axisType;
	yAxis.titleColor = lineColour;
	yAxis.tickLabelOffsetX = 2;
	return yAxis;
}

- (PWESAxis *)rightYAxisResultsTuple:(PWESDataTuple *)resultsTuple type:(NSString *)type
{
	if (self.types.isDualType)
	{
		NSString *axisType = self.types.secondaryType;
		UIColor *lineColour = [self colourForType:axisType];
		CGFloat ticksToUse = ([type isEqualToString:kViralLoad]) ? logTicks : ticks;
		PWESValueRange *range = [PWESValueRange valueRangeForDataTuple:resultsTuple ticks:ticks];


		PWESAxis *yAxis = [[PWESAxis alloc] initVerticalAxisWithFrame:yAxisFrameRight
		                                                   valueRange:range
		                                                  orientation:VerticalRight
		                                                        ticks:ticksToUse];
		yAxis.axisTitle = axisType;
		yAxis.titleColor = lineColour;
		yAxis.tickLabelOffsetX = 2;
		return yAxis;
	}
	else
	{
		return [[PWESAxis alloc] initVerticalAxisWithFrame:yAxisFrameRight
		                                       orientation:VerticalRight];
	}
}

- (PWESAxis *)xAxis
{
	return [[PWESAxis alloc] initHorizontalAxisWithFrame:xAxisFrame];
}

- (PWESAxis *)topAxis
{
	return [[PWESAxis alloc] initHorizontalAxisWithFrame:xAxisFrameTop];
}

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
	CGFloat ticksToUse = ([type isEqualToString:kViralLoad]) ? logTicks : ticks;
	PWESValueRange *range = [self valueRangeForType:type tickCounts:ticksToUse];
	UIColor *colour = [self colourForType:type];
	PWESPlotArea *area = [[PWESPlotArea alloc] initWithFrame:plotAreaFrame
	                                              lineColour:colour
	                                              valueRange:range
	                                                dateLine:self.ntuple.dateLine];
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
