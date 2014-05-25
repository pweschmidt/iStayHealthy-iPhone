//
//  PWESResultDatesPlotArea.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 25/05/2014.
//
//

#import "PWESResultDatesPlotArea.h"
#import "PWESDataNTuple.h"
static NSDateFormatter *shortResultsDate()
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = kShortDateFormatting;
	formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
	return formatter;
}

@interface PWESResultDatesPlotArea ()
{
	CGFloat xStart;
	CGFloat xEnd;
	CGFloat marginLabelBottom;
}
@property (nonatomic, assign) NSUInteger allDates;
@property (nonatomic, strong) PWESDataNTuple *ntuple;
@end

@implementation PWESResultDatesPlotArea
- (id)initWithFrame:(CGRect)frame
       marginBottom:(CGFloat)marginBottom
             ntuple:(PWESDataNTuple *)ntuple;
{
	self = [super initWithFrame:frame lineColour:nil valueRange:nil dateLine:ntuple.dateLine];
	if (nil != self)
	{
		_allDates = ntuple.dateLine.count;
		marginLabelBottom = marginBottom;
		_ntuple = ntuple;
	}
	return self;
}

- (void)plotDates
{
	if (nil == self.plotLayer)
	{
		return;
	}
	if (nil == self.plotLayer.delegate)
	{
		self.plotLayer.delegate = self;
	}
	NSUInteger length = self.allDates;
	if (0 == length)
	{
		length = 1;
	}
	CGFloat width = self.plotLayer.frame.size.width;

	xStart = (width / length);

	if (10 > length)
	{
		xStart = self.plotLayer.frame.size.width  / (length + 1);
	}

	CGFloat xDistance = xStart;
	xEnd = xStart + xDistance * (length - 1);

	CGFloat xOffsetLeft = xStart - 20;
	if (20 > xOffsetLeft)
	{
		xOffsetLeft = 0;
	}
	xStart = xOffsetLeft;

	CGFloat xOffsetRight = xEnd + 20;
	if (xOffsetRight > self.plotLayer.frame.size.width)
	{
		xOffsetRight = xEnd - 40;
	}
	xEnd = xOffsetRight;

	[self.plotLayer setNeedsDisplay];
}

- (void)drawLayer:(CALayer *)layer
        inContext:(CGContextRef)context
{
	NSDate *firstDate = self.ntuple.firstResultsDate;
	if (nil == firstDate)
	{
		return;
	}
	[self drawDate:context date:firstDate xValue:xStart yValue:self.plotLayer.frame.size.height - 5];
	if (1 < self.ntuple.maxNumberOfResults)
	{
		NSDate *lastDate = self.ntuple.lastResultsDate;
		[self drawDate:context date:lastDate xValue:xEnd yValue:self.plotLayer.frame.size.height - 5];
	}
}

@end
