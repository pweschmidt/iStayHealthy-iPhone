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

static NSDictionary *defaultAxisAttributes()
{
	NSDictionary *attributes = @{ kPlotAxisTitleFontSize : [NSNumber numberWithFloat:standard],
		                          kPlotAxisTickLabelFontSize : [NSNumber numberWithFloat:tiny],
		                          kPlotAxisTitleFontName : kDefaultLightFont,
		                          kPlotAxisTickFontName : kDefaultBoldFont,
		                          kPlotAxisTickLabelExpFontSize : [NSNumber numberWithFloat:veryTiny],
		                          kPlotAxisTickDistance : [NSNumber numberWithFloat:kPXTickDistance] };
	return attributes;
}

@interface PWESAxis ()
{
	CGRect axisFrame;
	CGFloat defaultTickLabelSize;
	CGFloat defaultAxisLabelSize;
	CGFloat tickDistance;
}
@property (nonatomic, assign) BOOL hasLabels;
@property (nonatomic, strong) NSArray *dateLine;
@property (nonatomic, assign) BOOL showAtBottom;
@property (nonatomic, strong) PWESValueRange *valueRange;
@end

@implementation PWESAxis

- (id)initWithFrame:(CGRect)frame orientation:(AxisType)orientation attributes:(NSDictionary *)attributes
{
	self = [super init];
	if (nil != self)
	{
		_orientation = orientation;
		_axisLayer = [CALayer layer];
		_axisLayer.frame = frame;
		_showAxisLabel = NO;
		if (nil == attributes)
		{
			attributes = defaultAxisAttributes();
		}
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
