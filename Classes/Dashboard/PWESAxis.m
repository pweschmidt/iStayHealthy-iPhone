//
//  PWESAxis.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 14/10/2013.
//
//

#import "PWESAxis.h"
#import "PWESUtils.h"
#import "UIFont+Standard.h"
#import "NSString+Extras.h"
#import "Utilities.h"
#import <CoreText/CoreText.h>

typedef NS_ENUM (int, AxisStyle)
{
	tick,
	exponentialTick,
	title
};

static NSDictionary *defaultAxisAttributes()
{
	NSDictionary *attributes = @{ kPlotAxisTitleFontSize : [NSNumber numberWithFloat:standard],
		                          kPlotAxisTickLabelFontSize : [NSNumber numberWithFloat:tiny],
		                          kPlotAxisTitleFontName : kDefaultLightFont,
		                          kPlotAxisTickFontName : kDefaultBoldFont,
		                          kPlotAxisTickLabelExpFontSize : [NSNumber numberWithFloat:veryTiny] };
	return attributes;
}

@interface PWESAxis ()
{
	CGRect axisFrame;
	CGFloat defaultTickLabelSize;
	CGFloat defaultAxisLabelSize;
}
@property (nonatomic, assign) BOOL hasLabels;
@property (nonatomic, strong) PWESValueRange *valueRange;
@end

@implementation PWESAxis

- (id)initVerticalAxisWithFrame:(CGRect)frame orientation:(AxisType)orientation
{
	return [self initVerticalAxisWithFrame:frame orientation:orientation attributes:defaultAxisAttributes()];
}

- (id)initVerticalAxisWithFrame:(CGRect)frame orientation:(AxisType)orientation
                     attributes:(NSDictionary *)attributes
{
	self = [super init];
	if (nil != self)
	{
		_orientation = orientation;
		_axisLayer = [CALayer layer];
		_axisLayer.frame = frame;
		_valueRange = nil;
		_hasLabels = YES;
		_ticks = 0;
		_tickLabelOffsetX = _tickLabelOffsetY = _tickLabelOffsetXRight = _tickLabelOffsetYRight = 2;
		_exponentialTickLabelOffset = 10;
		_axisAttributes = [NSDictionary dictionaryWithDictionary:attributes];
	}
	return self;
}

- (id)initVerticalAxisWithFrame:(CGRect)frame
                     valueRange:(PWESValueRange *)valueRange
                    orientation:(AxisType)orientation
                          ticks:(CGFloat)ticks
{
	return [self initVerticalAxisWithFrame:frame valueRange:valueRange orientation:orientation attributes:defaultAxisAttributes() ticks:ticks];
}

- (id)initVerticalAxisWithFrame:(CGRect)frame valueRange:(PWESValueRange *)valueRange orientation:(AxisType)orientation attributes:(NSDictionary *)attributes ticks:(CGFloat)ticks
{
	self = [super init];
	if (nil != self)
	{
		_orientation = orientation;
		_axisLayer = [CALayer layer];
		_axisLayer.frame = frame;
		_valueRange = valueRange;
		_hasLabels = YES;
		_ticks = ticks;
		_tickLabelOffsetX = _tickLabelOffsetY = _tickLabelOffsetXRight = _tickLabelOffsetYRight = 2;
		_exponentialTickLabelOffset = 10;
		_axisAttributes = [NSDictionary dictionaryWithDictionary:attributes];
	}
	return self;
}

- (id)initHorizontalAxisWithFrame:(CGRect)frame
{
	return [self initHorizontalAxisWithFrame:frame attributes:defaultAxisAttributes()];
}

- (id)initHorizontalAxisWithFrame:(CGRect)frame attributes:(NSDictionary *)attributes
{
	self = [super init];
	if (nil != self)
	{
		_orientation = Horizontal;
		_axisLayer = [CALayer layer];
		_axisLayer.frame = frame;
		_valueRange = nil;
		_ticks = 0;
		_hasLabels = NO;
		_axisAttributes = [NSDictionary dictionaryWithDictionary:attributes];
	}
	return self;
}

- (void)show
{
	if (nil == self.axisLayer)
	{
		return;
	}
	if (nil == self.axisLayer.delegate)
	{
		self.axisLayer.delegate = self;
	}
	[self.axisLayer setNeedsDisplay];
}

- (void)drawLayer:(CALayer *)layer
        inContext:(CGContextRef)context
{
	CGPoint axisStart;
	CGPoint axisEnd;

	CGRect frame = self.axisLayer.bounds;
	if (Vertical == self.orientation || VerticalRight == self.orientation)
	{
//		[self addAxisLabel:context frame:frame];
		axisStart = CGPointMake(frame.origin.x + frame.size.width / 2 + kAxisLineWidth / 2, frame.origin.y);
		axisEnd = CGPointMake(frame.origin.x + frame.size.width / 2 + kAxisLineWidth / 2, frame.size.height);
		[self addTickMarks:context frame:frame];
		if (self.hasLabels)
		{
			if ([self.valueRange.type isEqualToString:kViralLoad] || [self.valueRange.type isEqualToString:kHepCViralLoad])
			{
				[self addExponentialLabels:context frame:frame];
			}
			else
			{
				[self addLabels:context frame:frame];
			}
		}
	}
	else
	{
		axisStart = CGPointMake(frame.origin.x + kAxisLineWidth / 2, frame.origin.y + frame.size.height / 2 - kAxisLineWidth / 2);
		axisEnd = CGPointMake(frame.size.width, frame.origin.y + frame.size.height / 2 - kAxisLineWidth / 2);
	}
	[self drawLineWithContext:context start:axisStart end:axisEnd lineWidth:kAxisLineWidth cgColour:self.axisColor.CGColor];
}

- (void)addTickMarks:(CGContextRef)context frame:(CGRect)frame
{
//    CGFloat yOffset = frame.origin.y + kPXTickDistance;
	CGFloat yOffset = frame.size.height;
	CGFloat xStart = frame.origin.x + frame.size.width / 2 + kAxisLineWidth / 2 - kTickLength / 2;
	CGFloat xEnd = xStart + kTickLength;

	for (int tick = 0; tick < self.ticks; tick++)
	{
		CGPoint start = CGPointMake(xStart, yOffset);
		CGPoint end = CGPointMake(xEnd, yOffset);
		[self drawLineWithContext:context start:start end:end lineWidth:kAxisTickWidth cgColour:self.axisColor.CGColor];
		yOffset -= kPXTickDistance;
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
//    CGFloat yPosition = frame.origin.y + kPXTickDistance;
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
		yPosition -= kPXTickDistance;
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
		yPosition -= kPXTickDistance;
		expYPosition -= kPXTickDistance;
	}
}

- (void)addAxisLabel:(CGContextRef)context frame:(CGRect)frame
{
	if (nil == self.axisTitle || 0 == self.axisTitle.length)
	{
		return;
	}
	if (nil == self.titleColor)
	{
		self.titleColor = TEXTCOLOUR;
	}
	CGContextSaveGState(context);
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);

	CGFloat fontSize = [self fontSizeForAxisStyle:title];
	NSString *fontName = [self fontNameForAxisStyle:title];
	NSDictionary *attributes = @{ NSFontAttributeName:[UIFont fontWithName:fontName size:fontSize],
		                          NSForegroundColorAttributeName : self.titleColor };
	NSAttributedString *string = [[NSAttributedString alloc] initWithString:self.axisTitle attributes:attributes];

	CTLineRef displayLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)string);
	CGSize lineSize = [self sizeOfLine:displayLine];


	CGFloat angle = 0;
	if (Vertical == self.orientation)
	{
		CGFloat height = frame.size.height / 2 - lineSize.width;
		if (height < lineSize.width)
		{
			height = lineSize.width;
		}
		CGContextTranslateCTM(context, frame.size.width / 2 - lineSize.height, height);
		angle = M_PI_2;
	}
	else if (VerticalRight == self.orientation)
	{
		CGFloat height = frame.size.height / 4 - lineSize.width;
		if (height < lineSize.width)
		{
			height = lineSize.width;
		}
		CGContextTranslateCTM(context, frame.size.width / 2 + lineSize.height, height);
		angle = -M_PI_2;
	}
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextRotateCTM(context, angle);
	CTLineDraw(displayLine, context);
	CFRelease(displayLine);
	CGContextRestoreGState(context);
}

- (CGFloat)fontSizeForAxisStyle:(AxisStyle)style
{
	switch (style)
	{
		case tick:
		{
			NSNumber *number = [self.axisAttributes objectForKey:kPlotAxisTickLabelFontSize];
			if (nil == number)
			{
				return tiny;
			}
			else
			{
				return [number floatValue];
			}
		}

		case exponentialTick:
		{
			NSNumber *number = [self.axisAttributes objectForKey:kPlotAxisTickLabelExpFontSize];
			if (nil == number)
			{
				return veryTiny;
			}
			else
			{
				return [number floatValue];
			}
		}

		case title:
		{
			NSNumber *number = [self.axisAttributes objectForKey:kPlotAxisTitleFontSize];
			if (nil == number)
			{
				return standard;
			}
			else
			{
				return [number floatValue];
			}
		}
	}
}

- (NSString *)fontNameForAxisStyle:(AxisStyle)style
{
	switch (style)
	{
		case tick:
		{
			NSString *name = [self.axisAttributes objectForKey:kPlotAxisTickFontName];
			if (nil == name || 0 == name.length)
			{
				return kDefaultBoldFont;
			}
			else
			{
				return name;
			}
		}

		case exponentialTick:
		{
			NSString *name = [self.axisAttributes objectForKey:kPlotAxisTickFontName];
			if (nil == name || 0 == name.length)
			{
				return kDefaultBoldFont;
			}
			else
			{
				return name;
			}
		}

		case title:
		{
			NSString *name = [self.axisAttributes objectForKey:kPlotAxisTitleFontName];
			if (nil == name || 0 == name.length)
			{
				return kDefaultLightFont;
			}
			else
			{
				return name;
			}
		}
	}
}

- (CGSize)sizeOfLine:(CTLineRef)line
{
	CGFloat ascent;
	CGFloat descent;
	CGFloat width = CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
	CGFloat height = ascent + descent;
	return CGSizeMake(width, height);
}

@end
