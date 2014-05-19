//
//  PWESMedPlotArea.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 18/05/2014.
//
//

#import "PWESMedPlotArea.h"

@interface PWESMedPlotArea ()
{
	CGFloat xStart;
	CGFloat xDistance;
}
@property (nonatomic, assign) NSUInteger allDates;

@end

@implementation PWESMedPlotArea
- (id)initWithFrame:(CGRect)frame
           dateLine:(NSArray *)dateLine
{
	self = [super initWithFrame:frame lineColour:nil valueRange:nil dateLine:dateLine];
	if (nil != self)
	{
		_allDates = dateLine.count;
	}
	return self;
}

- (void)plotMedicationTuple:(PWESDataTuple *)tuple
{
	self.lineColor = [UIColor lightGrayColor];
	NSUInteger length = self.dateLine.count;
	[self configureBeforePlottingTuple:tuple tupleLength:length];
}

- (void)plotMissedMedicationTuple:(PWESDataTuple *)tuple
{
	self.lineColor = DARK_RED;
	NSUInteger length = self.dateLine.count;
	[self configureBeforePlottingTuple:tuple tupleLength:length];
}

- (void)configureBeforePlottingTuple:(PWESDataTuple *)tuple tupleLength:(NSUInteger)tupleLength
{
	if (nil == self.plotLayer)
	{
		return;
	}
	if (nil == self.plotLayer.delegate)
	{
		self.plotLayer.delegate = self;
	}
	if (!tuple.isEmpty)
	{
		self.tuple = tuple;
		NSUInteger length = self.allDates;
		if (0 == length)
		{
			length = 1;
		}
		CGFloat width = self.plotLayer.frame.size.width;

		xStart = (width / length);
		xDistance = xStart;

		if (10 > length)
		{
			xStart = self.plotLayer.frame.size.width  / (length + 1);
		}
		[self.plotLayer setNeedsDisplay];
	}
}

- (void)drawLayer:(CALayer *)layer
        inContext:(CGContextRef)context
{
	int index = 0;
	for (id dateObject in self.dateLine)
	{
		CGFloat xValue = xStart + xDistance * index;
		id value = [self.tuple valueForDate:dateObject];
		if (nil != value)
		{
			CGPoint start = CGPointMake(xValue, self.plotLayer.frame.origin.y);
			CGPoint end = CGPointMake(xValue, self.plotLayer.frame.size.height);
			[self drawLineWithContext:context start:start end:end lineWidth:kAxisLineWidth cgColour:self.lineColor.CGColor fillColour:self.lineColor.CGColor pattern:medDashPattern patternCount:2];
		}
		index++;
	}
}

@end
