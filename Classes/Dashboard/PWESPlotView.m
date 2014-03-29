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
#import "GeneralSettings.h"
#import "ChartSettings.h"
#import "Constants.h"
#import "UIFont+Standard.h"
#import <QuartzCore/QuartzCore.h>

@interface PWESPlotView ()
{
	CGRect plotBoundaries;
	CGFloat ticks;
}
@property (nonatomic, strong) PWESAxis *xAxis;
@property (nonatomic, strong) PWESAxis *yAxis;
@property (nonatomic, strong) PWESAxis *yAxisRight;
@property (nonatomic, strong) PWESAxis *xAxisTop;
@property (nonatomic, strong) PWESPlotArea *plotArea;
@property (nonatomic, strong) PWESPlotArea *secondPlotArea;
@property (nonatomic, strong) NSArray *types;
@property (nonatomic, strong) PWESDataNTuple *ntuple;
@property (nonatomic, strong) NSArray *medications;
@property (nonatomic, strong) PWESDataTuple *firstTuple;
@property (nonatomic, strong) PWESDataTuple *secondTuple;
@end

@implementation PWESPlotView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		_marginBottom = _marginLeft = _marginRight = _marginTop = 20;
	}
	return self;
}

+ (PWESPlotView *)plotViewWithFrame:(CGRect)frame
                             nTuple:(PWESDataNTuple *)nTuple
                        medications:(NSArray *)medications
                              types:(NSArray *)types
{
	PWESPlotView *plotView = [[PWESPlotView alloc] initWithFrame:frame];
	plotView.pxTickDistance = kPXTickDistance;
	plotView.ntuple = nTuple;
	plotView.medications = medications;
	plotView.types = types;
	[plotView configurePlotView];
	return plotView;
}

- (void)configurePlotView
{
	if (self.ntuple.isEmpty)
	{
		UILabel *emptyLabel = [[UILabel alloc] init];
		emptyLabel.frame = CGRectMake(self.bounds.origin.x + self.bounds.size.width / 2 - 100, self.bounds.origin.y + self.bounds.size.height / 2 - 50, 200, 100);
		emptyLabel.backgroundColor = [UIColor clearColor];
		emptyLabel.textAlignment = NSTextAlignmentCenter;
		emptyLabel.textColor = TEXTCOLOUR;
		emptyLabel.font = [UIFont fontWithType:Light size:20];
		emptyLabel.text = NSLocalizedString(@"No results available", nil);
		[self addSubview:emptyLabel];
		return;
	}


	CGRect yAxisFrame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.marginLeft * 2, self.bounds.size.height - self.marginBottom);

	CGRect yAxisFrameRight = CGRectMake(self.bounds.origin.x + self.bounds.size.width - self.marginRight - self.marginLeft - 3, self.bounds.origin.y, self.marginLeft * 2, self.bounds.size.height - self.marginBottom);

	ticks = roundf(yAxisFrame.size.height / self.pxTickDistance);

	CGRect xAxisFrame = CGRectMake(self.bounds.origin.x + self.marginLeft, self.bounds.size.height - self.marginBottom - self.marginTop, self.bounds.size.width - self.marginRight - self.marginLeft, self.marginBottom * 2);

	CGRect xAxisFrameTop = CGRectMake(self.bounds.origin.x + self.marginLeft, 0 - self.marginTop, self.bounds.size.width - self.marginRight - self.marginLeft, self.marginBottom * 2);

	CGRect plotFrame = CGRectMake(self.bounds.origin.x + self.marginLeft, self.bounds.origin.y, self.bounds.size.width - self.marginRight - self.marginLeft, self.bounds.size.height - self.marginBottom);



	self.firstTuple = [self.ntuple tupleForType:[self.types objectAtIndex:0]];
	PWESValueRange *rangeLeft = [PWESValueRange valueRangeForDataTuple:self.firstTuple ticks:ticks];


	self.yAxis = [[PWESAxis alloc] initVerticalAxisWithFrame:yAxisFrame
	                                              valueRange:rangeLeft
	                                             orientation:Vertical
	                                                   ticks:ticks];
	if (self.yAxis.axisLayer)
	{
		[self.layer addSublayer:self.yAxis.axisLayer];
		[self.yAxis show];
	}
	self.xAxis = [[PWESAxis alloc] initHorizontalAxisWithFrame:xAxisFrame];
	if (self.xAxis)
	{
		[self.layer addSublayer:self.xAxis.axisLayer];
		[self.xAxis show];
	}

	self.xAxisTop = [[PWESAxis alloc] initHorizontalAxisWithFrame:xAxisFrameTop];
	if (self.xAxisTop)
	{
		[self.layer addSublayer:self.xAxisTop.axisLayer];
		[self.xAxisTop show];
	}

	UIColor *lineColour = [self colourForType:[self.types objectAtIndex:0]];
	self.plotArea = [[PWESPlotArea alloc] initWithFrame:plotFrame
	                                         lineColour:lineColour
	                                         valueRange:rangeLeft
	                                           dateLine:self.ntuple.dateLine
	                                              ticks:ticks];

	if (self.plotArea)
	{
		[self.layer addSublayer:self.plotArea.plotLayer];
		[self.plotArea plotDataTuple:self.firstTuple];
	}


	if (2 == self.types.count)
	{
		self.secondTuple = [self.ntuple tupleForType:[self.types objectAtIndex:1]];
		PWESValueRange *rangeRight = [PWESValueRange valueRangeForDataTuple:self.secondTuple ticks:ticks];
		self.yAxisRight = [[PWESAxis alloc] initVerticalAxisWithFrame:yAxisFrameRight
		                                                   valueRange:rangeRight
		                                                  orientation:VerticalRight
		                                                        ticks:ticks];
		if (self.yAxisRight.axisLayer)
		{
			[self.layer addSublayer:self.yAxisRight.axisLayer];
			[self.yAxisRight show];
		}
		UIColor *secondColour = [self colourForType:[self.types objectAtIndex:1]];
		self.secondPlotArea = [[PWESPlotArea alloc] initWithFrame:plotFrame lineColour:secondColour valueRange:rangeRight dateLine:self.ntuple.dateLine ticks:ticks];
		if (self.secondPlotArea)
		{
			[self.layer addSublayer:self.secondPlotArea.plotLayer];
			[self.secondPlotArea plotDataTuple:self.secondTuple];
		}
	}
	else
	{
		self.yAxisRight = [[PWESAxis alloc] initVerticalAxisWithFrame:yAxisFrameRight
		                                                  orientation:VerticalRight];
		if (self.yAxisRight.axisLayer)
		{
			[self.layer addSublayer:self.yAxisRight.axisLayer];
			[self.yAxisRight show];
		}
	}
}

/*
   // Only override drawRect: if you perform custom drawing.
   // An empty implementation adversely affects performance during animation.
   - (void)drawRect:(CGRect)rect
   {
    // Drawing code
   }
 */
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
