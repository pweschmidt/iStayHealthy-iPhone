//
//  PWESVerticalAxis.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 25/05/2014.
//
//

#import "PWESVerticalAxis.h"
#import "PWESUtils.h"
#import "UIFont+Standard.h"
#import "NSString+Extras.h"
#import "Utilities.h"
#import <CoreText/CoreText.h>

@interface PWESVerticalAxis ()
{
	CGRect axisFrame;
	CGFloat defaultTickLabelSize;
	CGFloat defaultAxisLabelSize;
	CGFloat tickDistance;
}
@property (nonatomic, assign) BOOL hasLabels;
@property (nonatomic, assign) BOOL isLog10Axis;
@property (nonatomic, strong) PWESValueRange *valueRange;
@end

@implementation PWESVerticalAxis
- (id)initVerticalAxisWithFrame:(CGRect)frame
                    orientation:(AxisType)orientation
{
	return [self initVerticalAxisWithFrame:frame orientation:orientation attributes:nil];
}

- (id)initVerticalAxisWithFrame:(CGRect)frame
                    orientation:(AxisType)orientation
                     attributes:(NSDictionary *)attributes
{
	self = [super initWithFrame:frame orientation:orientation attributes:attributes];
	if (nil != self)
	{
		_valueRange = nil;
		_hasLabels = YES;
		self.ticks = 0;
		self.tickLabelOffsetX = self.tickLabelOffsetY = self.tickLabelOffsetXRight = self.tickLabelOffsetYRight = 2;
		_isLog10Axis = NO;
		tickDistance = kPXTickDistance;
	}
	return self;
}

- (id)initVerticalAxisWithFrame:(CGRect)frame
                     valueRange:(PWESValueRange *)valueRange
                    orientation:(AxisType)orientation
                          ticks:(CGFloat)ticks
{
	return [self initVerticalAxisWithFrame:frame valueRange:valueRange orientation:orientation attributes:nil ticks:ticks];
}

- (id)initVerticalAxisWithFrame:(CGRect)frame
                     valueRange:(PWESValueRange *)valueRange
                    orientation:(AxisType)orientation
                     attributes:(NSDictionary *)attributes
                          ticks:(CGFloat)ticks
{
	self = [super initWithFrame:frame orientation:orientation attributes:attributes];
	if (nil != self)
	{
		_valueRange = valueRange;
		_hasLabels = YES;
		self.ticks = ticks;
		self.tickLabelOffsetX = self.tickLabelOffsetY = self.tickLabelOffsetXRight = self.tickLabelOffsetYRight = 2;
		tickDistance = kPXTickDistance;
	}
	return self;
}

- (id)initVerticalLogAxisWithFrame:(CGRect)frame
                        valueRange:(PWESValueRange *)valueRange
                       orientation:(AxisType)orientation
                   logTickDistance:(CGFloat)logTickDistance
{
	self = [super initWithFrame:frame orientation:orientation attributes:nil];
	if (nil != self)
	{
		_valueRange = valueRange;
		_hasLabels = YES;
		self.ticks = kMaxLog10Ticks;
		self.tickLabelOffsetX = self.tickLabelOffsetY = self.tickLabelOffsetXRight = self.tickLabelOffsetYRight = 2;
		self.isLog10Axis = YES;
		self.exponentialTickLabelOffset = 10;
		tickDistance = logTickDistance;
	}
	return self;
}

- (void)drawLayer:(CALayer *)layer
        inContext:(CGContextRef)context
{
	CGPoint axisStart;
	CGPoint axisEnd;

	CGRect frame = self.axisLayer.bounds;
	axisStart = CGPointMake(frame.origin.x + frame.size.width / 2 + kAxisLineWidth / 2, frame.origin.y);
	axisEnd = CGPointMake(frame.origin.x + frame.size.width / 2 + kAxisLineWidth / 2, frame.size.height);
	[self addTickMarks:context frame:frame];
	if (self.hasLabels)
	{
		if (self.isLog10Axis)
		{
			[self addExponentialLabels:context frame:frame];
		}
		else
		{
			[self addLabels:context frame:frame];
		}
	}
	[self drawLineWithContext:context start:axisStart end:axisEnd lineWidth:kAxisLineWidth cgColour:self.axisColor.CGColor];
}

- (void)addTickMarks:(CGContextRef)context frame:(CGRect)frame
{
	CGFloat yOffset = frame.size.height;
	CGFloat xStart = frame.origin.x + frame.size.width / 2 + kAxisLineWidth / 2 - kTickLength / 2;
	CGFloat xEnd = xStart + kTickLength;

	for (int tick = 0; tick < self.ticks; tick++)
	{
		CGPoint start = CGPointMake(xStart, yOffset);
		CGPoint end = CGPointMake(xEnd, yOffset);
		[self drawLineWithContext:context start:start end:end lineWidth:kAxisTickWidth cgColour:self.axisColor.CGColor];
		yOffset -= tickDistance;
	}
}

- (void)addLabels:(CGContextRef)context frame:(CGRect)frame
{
	if (Horizontal == self.orientation || nil == self.valueRange)
	{
		return;
	}
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
	CGFloat fontSize = [self fontSizeForAxisStyle:tick];
	NSString *fontName = [self fontNameForAxisStyle:tick];
	NSDictionary *attributes = @{ NSFontAttributeName:[UIFont fontWithName:fontName size:fontSize] };

	CGFloat xPosition = frame.origin.x + self.tickLabelOffsetX;
	CGFloat yPosition = frame.size.height - self.tickLabelOffsetY;
	if (VerticalRight == self.orientation)
	{
		xPosition += kAxisLineWidth / 2 + self.tickLabelOffsetXRight;
		yPosition = frame.size.height - self.tickLabelOffsetYRight;
	}
	CGFloat min = [self.valueRange.minValue floatValue];
	for (int tick = 0; tick < self.ticks; ++tick)
	{
		NSString *label = [[NSString alloc] valueStringForType:self.valueRange.type valueAsFloat:min];
		if ([label isEqualToString:NSLocalizedString(@"Enter Value", nil)])
		{
			label = @"";
		}
		NSAttributedString *string = [[NSAttributedString alloc] initWithString:label attributes:attributes];
		CTLineRef displayLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)string);
		CGContextSetTextPosition(context, xPosition, yPosition);
		CTLineDraw(displayLine, context);
		CFRelease(displayLine);
		min += self.valueRange.tickDeltaValue;
		yPosition -= tickDistance;
	}
}

- (void)addExponentialLabels:(CGContextRef)context frame:(CGRect)frame
{
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
	CGFloat fontSize = [self fontSizeForAxisStyle:tick];
	NSString *fontName = [self fontNameForAxisStyle:tick];
	NSDictionary *attributes = @{ NSFontAttributeName:[UIFont fontWithName:fontName size:fontSize] };
	CGFloat xPosition = frame.origin.x + self.tickLabelOffsetX;
	CGFloat yPosition = frame.size.height - self.tickLabelOffsetY;
	if (VerticalRight == self.orientation)
	{
		xPosition += frame.size.width / 2 + self.tickLabelOffsetXRight;
		yPosition = frame.size.height - self.tickLabelOffsetYRight;
	}

	CGFloat expSize = [self fontSizeForAxisStyle:exponentialTick];
	NSString *expFontName = [self fontNameForAxisStyle:exponentialTick];
	NSDictionary *expAttributes = @{ NSFontAttributeName:[UIFont fontWithName:expFontName size:expSize] };

	CGFloat expXPosition = xPosition + self.exponentialTickLabelOffset;
	CGFloat expYPosition = yPosition - expSize;

	CGFloat min = 0.1;
	int exponentValue = -1;
	for (int tick = 0; tick < self.ticks; ++tick)
	{
		NSString *label = nil;
		NSString *exponent = nil;
		if (1 > min)
		{
			label = @"";
		}
		else if (10 > min)
		{
			label = NSLocalizedString(@"und.", nil);
		}
		else if (1000 > min)
		{
			label = [NSString stringWithFormat:@"%d", (int)min];
		}
		else
		{
			label = @"10";
			exponent = [NSString stringWithFormat:@"%d", exponentValue];
		}
		NSAttributedString *string = [[NSAttributedString alloc] initWithString:label attributes:attributes];
		CTLineRef displayLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)string);
		CGContextSetTextPosition(context, xPosition, yPosition);
		CTLineDraw(displayLine, context);
		CFRelease(displayLine);

		if (nil != exponent)
		{
			NSAttributedString *expstring = [[NSAttributedString alloc] initWithString:exponent
			                                                                attributes:expAttributes];
			CTLineRef extdisplayLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)expstring);
			CGContextSetTextPosition(context, expXPosition, expYPosition);
			CTLineDraw(extdisplayLine, context);
			CFRelease(extdisplayLine);
		}

		min *= 10;
		exponentValue++;
		yPosition -= tickDistance;
		expYPosition -= tickDistance;
	}
}

@end
