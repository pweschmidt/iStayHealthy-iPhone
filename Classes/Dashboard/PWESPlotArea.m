//
//  PWESPlotArea.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 15/10/2013.
//
//

#import "PWESPlotArea.h"

@interface PWESPlotArea ()
{
	CGFloat xStart;
	CGFloat xDistance;
	CGFloat red;
	CGFloat green;
	CGFloat blue;
	CGFloat alpha;
}
@property (nonatomic, strong) UIColor *lineColour;
@property (nonatomic, assign) BOOL isToDrawPoints;
@end

@implementation PWESPlotArea

- (id)initWithFrame:(CGRect)frame
         lineColour:(UIColor *)lineColour
         valueRange:(PWESValueRange *)valueRange
           dateLine:(NSArray *)dateLine
{
	return [self initWithFrame:frame lineColour:lineColour valueRange:valueRange dateLine:dateLine tickDistance:kPXTickDistance];
}

- (id)initWithFrame:(CGRect)frame
         lineColour:(UIColor *)lineColour
         valueRange:(PWESValueRange *)valueRange
           dateLine:(NSArray *)dateLine
       tickDistance:(CGFloat)tickDistance
{
	self = [super init];
	if (nil != self)
	{
		_lineWidth = 2.0;
		_isToDrawPoints = NO;
		_plotLayer = [CALayer layer];
		_plotLayer.frame = frame;
		_lineColour = lineColour;
		_valueRange = valueRange;
		_dateLine = dateLine;
		xStart = 0;
		_pxTickDistance = tickDistance;
	}
	return self;
}

- (void)plotDataTuple:(PWESDataTuple *)tuple
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
		NSUInteger length = self.dateLine.count;
		if (50 > length)
		{
			self.isToDrawPoints = YES;
		}
		[self configureBeforePlottingTuple:tuple tupleLength:length];
		[self.plotLayer setNeedsDisplay];
	}
}

- (void)configureBeforePlottingTuple:(PWESDataTuple *)tuple tupleLength:(NSUInteger)tupleLength
{
	self.tuple = tuple;
	if (0 == tupleLength)
	{
		tupleLength = 1;
	}
	CGFloat width = self.plotLayer.frame.size.width;

	xStart = (width / tupleLength);
	xDistance = xStart;

	if (10 > tupleLength)
	{
		xStart = self.plotLayer.frame.size.width  / (tupleLength + 1);
	}
}

- (void)drawLayer:(CALayer *)layer
        inContext:(CGContextRef)context
{
	CGFloat previousX = -1;
	CGFloat previousY = -1;
	int index = 0;
	for (id dateObject in self.dateLine)
	{
		id value = [self.tuple valueForDate:dateObject];
		CGFloat xValue = xStart + xDistance * index;
		if (nil != value)
		{
			CGFloat yValue = [self yOffetForValue:value];
			if (0 < yValue)
			{
				if (self.isToDrawPoints)
				{
					CGPoint point = CGPointMake(xValue - kAxisLineWidth / 2, yValue - kAxisLineWidth / 2);
					[self drawRectWithContext:context
					                    point:point
					                 cgColour:self.lineColour.CGColor
					               fillColour:self.lineColour.CGColor];
				}

				if (0 < previousY)
				{
					CGPoint start = CGPointMake(previousX, previousY);
					CGPoint end = CGPointMake(xValue, yValue);
					[self drawLineWithContext:context
					                    start:start
					                      end:end
					                lineWidth:kAxisLineWidth
					                 cgColour:self.lineColour.CGColor
					               fillColour:self.lineColour.CGColor];
				}
				previousY = yValue;
				previousX = xValue;
			}
		}
		index++;
	}
}

- (CGFloat)yOffetForValue:(id)value
{
	if (![value isKindOfClass:[NSNumber class]])
	{
		return -1;
	}
	NSNumber *number = (NSNumber *)value;
	if ([self.tuple.type isEqualToString:kHepCViralLoad] ||
	    [self.tuple.type isEqualToString:kViralLoad])
	{
		return [self logYOffsetForValue:number];
	}
	else
	{
		return [self linearYOffsetForValue:number];
	}
}

- (CGFloat)linearYOffsetForValue:(NSNumber *)value
{
	CGFloat scalingFactor = self.pxTickDistance / self.valueRange.tickDeltaValue;
	CGFloat actualValue = [value floatValue];
	CGFloat y = (actualValue * scalingFactor);
	CGFloat min = [self.valueRange.minValue floatValue];
	if (0 < min)
	{
		CGFloat ticks = min / self.valueRange.tickDeltaValue;
		ticks *= self.pxTickDistance;
		y -= ticks;
	}
	return (self.plotLayer.frame.size.height - y);
}

- (CGFloat)logYOffsetForValue:(NSNumber *)value
{
	CGFloat y =  log10f([value floatValue]) * self.pxTickDistance;
	CGFloat min = [self.valueRange.minValue floatValue];
	if (1 > min)
	{
		y += self.pxTickDistance;
	}
	return (self.plotLayer.frame.size.height - y);
}

@end
