//
//  GradientButton.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 18/08/2012.
//
//

#import "GradientButton.h"

@interface GradientButton ()
@property (nonatomic, readonly) CGGradientRef normalGradient;
@property (nonatomic, readonly) CGGradientRef highlightGradient;
- (void)useRedDeleteStyle;
- (void)useWhiteStyle;
- (void)useSimpleOrangeStyle;
- (void)useGreenConfirmStyle;
- (void)hesitateUpdate; 
@end

@implementation GradientButton
@synthesize normalGradient = _normalGradient;
@synthesize highlightGradient = _highlightGradient;

#pragma mark initialise methods
+ (GradientButton *)buttonWithFrame:(CGRect)frame title:(NSString *)titleText
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    GradientButton *gradButton = (GradientButton *)button;
    gradButton.frame = frame;
    [gradButton setTitle:titleText forState:UIControlStateNormal];
    [gradButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [gradButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    gradButton.opaque = NO;
    gradButton.backgroundColor = [UIColor clearColor];
    return gradButton;
}


- (void)setColourIndex:(NSInteger)index
{
    switch (index)
    {
        case Red:
            [self useRedDeleteStyle];
            break;
        case Green:
            [self useGreenConfirmStyle];
            break;
        case Orange:
            [self useSimpleOrangeStyle];
            break;
        default:
            [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self useWhiteStyle];
            break;
    }
    self.cornerRadius = 9.f;
}


- (id)initWithFrame:(CGRect)frame colour:(int)colourIndex title:(NSString *)titleText
{
    self = [super initWithFrame:frame];
    if (nil != self)
    {
		[self setOpaque:NO];
        self.backgroundColor = [UIColor clearColor];
        self.cornerRadius = 9.f;
        [self setTitle:titleText forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        switch (colourIndex)
        {
            case Red:
                [self useRedDeleteStyle];
                break;
            case Green:
                [self useGreenConfirmStyle];
                break;
            case Orange:
                [self useSimpleOrangeStyle];
                break;
            default:
                [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [self useWhiteStyle];
                break;
        }
        
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
		[self setOpaque:NO];
        self.backgroundColor = [UIColor clearColor];
        self.cornerRadius = 9.f;
        [self useWhiteStyle];
    }
    return self;
}

- (void)dealloc
{
    if (_normalGradient != NULL)
        CGGradientRelease(_normalGradient);
    if (_highlightGradient != NULL)
        CGGradientRelease(_highlightGradient);
    
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:[self normalGradientColors] forKey:@"normalGradientColors"];
    [encoder encodeObject:[self normalGradientLocations] forKey:@"normalGradientLocations"];
    [encoder encodeObject:[self highlightGradientColors] forKey:@"highlightGradientColors"];
    [encoder encodeObject:[self highlightGradientLocations] forKey:@"highlightGradientLocations"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder:decoder])
    {
        [self setNormalGradientColors:[decoder decodeObjectForKey:@"normalGradientColors"]];
        [self setNormalGradientLocations:[decoder decodeObjectForKey:@"normalGradientLocations"]];
        [self setHighlightGradientColors:[decoder decodeObjectForKey:@"highlightGradientColors"]];
        [self setHighlightGradientLocations:[decoder decodeObjectForKey:@"highlightGradientLocations"]];
        self.strokeColor = [UIColor colorWithRed:0.076 green:0.103 blue:0.195 alpha:1.0];
        self.strokeWeight = 1.0;
        
        if (self.normalGradientColors == nil)
            [self useWhiteStyle];
        
        [self setOpaque:NO];
        self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0];
    }
    return self;
}


#pragma mark Colour and Gradient setups

- (void)useRedDeleteStyle
{
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:5];
    UIColor *color = [UIColor colorWithRed:0.667 green:0.15 blue:0.152 alpha:1.0];
    [colors addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.841 green:0.566 blue:0.566 alpha:1.0];
    [colors addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.75 green:0.341 blue:0.345 alpha:1.0];
    [colors addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.592 green:0.0 blue:0.0 alpha:1.0];
    [colors addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.592 green:0.0 blue:0.0 alpha:1.0];
    [colors addObject:(id)[color CGColor]];
    self.normalGradientColors = colors;
    self.normalGradientLocations = [NSArray arrayWithObjects:
                                    [NSNumber numberWithFloat:0.0f],
                                    [NSNumber numberWithFloat:1.0f],
                                    [NSNumber numberWithFloat:0.582f],
                                    [NSNumber numberWithFloat:0.418f],
                                    [NSNumber numberWithFloat:0.346],
                                    nil];
    
    NSMutableArray *colors2 = [NSMutableArray arrayWithCapacity:5];
    color = [UIColor colorWithRed:0.467 green:0.009 blue:0.005 alpha:1.0];
    [colors2 addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.754 green:0.562 blue:0.562 alpha:1.0];
    [colors2 addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.543 green:0.212 blue:0.212 alpha:1.0];
    [colors2 addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.5 green:0.153 blue:0.152 alpha:1.0];
    [colors2 addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.388 green:0.004 blue:0.0 alpha:1.0];
    [colors addObject:(id)[color CGColor]];
    
    self.highlightGradientColors = colors;
    self.highlightGradientLocations = [NSArray arrayWithObjects:
                                       [NSNumber numberWithFloat:0.0f],
                                       [NSNumber numberWithFloat:1.0f],
                                       [NSNumber numberWithFloat:0.715f],
                                       [NSNumber numberWithFloat:0.513f],
                                       [NSNumber numberWithFloat:0.445f],
                                       nil];
    
}
- (void)useWhiteStyle
{
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:3];
	UIColor *color = [UIColor colorWithRed:0.864 green:0.864 blue:0.864 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.995 green:0.995 blue:0.995 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.956 green:0.956 blue:0.955 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
    self.normalGradientColors = colors;
    self.normalGradientLocations = [NSMutableArray arrayWithObjects:
                                    [NSNumber numberWithFloat:0.0f],
                                    [NSNumber numberWithFloat:1.0f],
                                    [NSNumber numberWithFloat:0.601f],
                                    nil];
    
    NSMutableArray *colors2 = [NSMutableArray arrayWithCapacity:3];
	color = [UIColor colorWithRed:0.692 green:0.692 blue:0.691 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.995 green:0.995 blue:0.995 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.83 green:0.83 blue:0.83 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
    self.highlightGradientColors = colors2;
    self.highlightGradientLocations = [NSMutableArray arrayWithObjects:
                                       [NSNumber numberWithFloat:0.0f],
                                       [NSNumber numberWithFloat:1.0f],
                                       [NSNumber numberWithFloat:0.601f],
                                       nil];
    
}
- (void)useSimpleOrangeStyle
{
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:2];
	UIColor *color = [UIColor colorWithRed:0.935 green:0.403 blue:0.02 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.97 green:0.582 blue:0.0 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
    self.normalGradientColors = colors;
    self.normalGradientLocations = [NSMutableArray arrayWithObjects:
                                    [NSNumber numberWithFloat:0.0f],
                                    [NSNumber numberWithFloat:1.0f],
                                    nil];
    
    NSMutableArray *colors2 = [NSMutableArray arrayWithCapacity:3];
	color = [UIColor colorWithRed:0.914 green:0.309 blue:0.0 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.935 green:0.4 blue:0.0 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.946 green:0.441 blue:0.01 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
    self.highlightGradientColors = colors2;
    self.highlightGradientLocations = [NSMutableArray arrayWithObjects:
                                       [NSNumber numberWithFloat:0.0f],
                                       [NSNumber numberWithFloat:1.0f],
                                       [NSNumber numberWithFloat:0.498f],
                                       nil];
    
}
- (void)useGreenConfirmStyle
{
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:5];
    UIColor *color = [UIColor colorWithRed:0.15 green:0.667 blue:0.152 alpha:1.0];
    [colors addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.566 green:0.841 blue:0.566 alpha:1.0];
    [colors addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.341 green:0.75 blue:0.345 alpha:1.0];
    [colors addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.0 green:0.592 blue:0.0 alpha:1.0];
    [colors addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.0 green:0.592 blue:0.0 alpha:1.0];
    [colors addObject:(id)[color CGColor]];
    self.normalGradientColors = colors;
    self.normalGradientLocations = [NSMutableArray arrayWithObjects:
                                    [NSNumber numberWithFloat:0.0f],
                                    [NSNumber numberWithFloat:1.0f],
                                    [NSNumber numberWithFloat:0.582f],
                                    [NSNumber numberWithFloat:0.418f],
                                    [NSNumber numberWithFloat:0.346],
                                    nil];
    
    NSMutableArray *colors2 = [NSMutableArray arrayWithCapacity:5];
    color = [UIColor colorWithRed:0.009 green:0.467 blue:0.005 alpha:1.0];
    [colors2 addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.562 green:0.754 blue:0.562 alpha:1.0];
    [colors2 addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.212 green:0.543 blue:0.212 alpha:1.0];
    [colors2 addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.153 green:0.5 blue:0.152 alpha:1.0];
    [colors2 addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.004 green:0.388 blue:0.0 alpha:1.0];
    [colors addObject:(id)[color CGColor]];
	
    self.highlightGradientColors = colors;
    self.highlightGradientLocations = [NSMutableArray arrayWithObjects:
                                       [NSNumber numberWithFloat:0.0f],
                                       [NSNumber numberWithFloat:1.0f],
                                       [NSNumber numberWithFloat:0.715f],
                                       [NSNumber numberWithFloat:0.513f],
                                       [NSNumber numberWithFloat:0.445f],
                                       nil];
    
}

- (CGGradientRef)normalGradient
{
    int locCount = self.normalGradientLocations.count;
    CGFloat locations[locCount];
    for (int i = 0; i < [self.normalGradientLocations count]; i++)
    {
        NSNumber *location = [self.normalGradientLocations objectAtIndex:i];
        locations[i] = [location floatValue];
    }
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
    _normalGradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)self.normalGradientColors, locations);
    if (space)
    {
        CGColorSpaceRelease(space);
    }
    return _normalGradient;
}

- (CGGradientRef)highlightGradient
{
    
    CGFloat locations[[self.highlightGradientLocations count]];
    for (int i = 0; i < [self.highlightGradientLocations count]; i++)
    {
        NSNumber *location = [self.highlightGradientLocations objectAtIndex:i];
        locations[i] = [location floatValue];
    }
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
    _highlightGradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)self.highlightGradientColors, locations);
    if (space)
    {
        CGColorSpaceRelease(space);
    }
    return _highlightGradient;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
*/
- (void)drawRect:(CGRect)rect
{
    self.backgroundColor = [UIColor clearColor];
	CGRect imageBounds = CGRectMake(0.0, 0.0, self.bounds.size.width - 0.5, self.bounds.size.height);
    
    
	CGGradientRef gradient;
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGPoint point2;
    
	CGFloat resolution = 0.5 * (self.bounds.size.width / imageBounds.size.width + self.bounds.size.height / imageBounds.size.height);
	
	CGFloat stroke = self.strokeWeight * resolution;
	if (stroke < 1.0)
		stroke = ceil(stroke);
	else
		stroke = round(stroke);
	stroke /= resolution;
	CGFloat alignStroke = fmod(0.5 * stroke * resolution, 1.0);
	CGMutablePathRef path = CGPathCreateMutable();
	CGPoint point = CGPointMake((self.bounds.size.width - self.cornerRadius), self.bounds.size.height - 0.5f);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(self.bounds.size.width - 0.5f, (self.bounds.size.height - self.cornerRadius));
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPoint controlPoint1 = CGPointMake((self.bounds.size.width - (self.cornerRadius / 2.f)), self.bounds.size.height - 0.5f);
	controlPoint1.x = (round(resolution * controlPoint1.x + alignStroke) - alignStroke) / resolution;
	controlPoint1.y = (round(resolution * controlPoint1.y + alignStroke) - alignStroke) / resolution;
	CGPoint controlPoint2 = CGPointMake(self.bounds.size.width - 0.5f, (self.bounds.size.height - (self.cornerRadius / 2.f)));
	controlPoint2.x = (round(resolution * controlPoint2.x + alignStroke) - alignStroke) / resolution;
	controlPoint2.y = (round(resolution * controlPoint2.y + alignStroke) - alignStroke) / resolution;
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(self.bounds.size.width - 0.5f, self.cornerRadius);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake((self.bounds.size.width - self.cornerRadius), 0.0);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	controlPoint1 = CGPointMake(self.bounds.size.width - 0.5f, (self.cornerRadius / 2.f));
	controlPoint1.x = (round(resolution * controlPoint1.x + alignStroke) - alignStroke) / resolution;
	controlPoint1.y = (round(resolution * controlPoint1.y + alignStroke) - alignStroke) / resolution;
	controlPoint2 = CGPointMake((self.bounds.size.width - (self.cornerRadius / 2.f)), 0.0);
	controlPoint2.x = (round(resolution * controlPoint2.x + alignStroke) - alignStroke) / resolution;
	controlPoint2.y = (round(resolution * controlPoint2.y + alignStroke) - alignStroke) / resolution;
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(self.cornerRadius, 0.0);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(0.0, self.cornerRadius);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	controlPoint1 = CGPointMake((self.cornerRadius / 2.f), 0.0);
	controlPoint1.x = (round(resolution * controlPoint1.x + alignStroke) - alignStroke) / resolution;
	controlPoint1.y = (round(resolution * controlPoint1.y + alignStroke) - alignStroke) / resolution;
	controlPoint2 = CGPointMake(0.0, (self.cornerRadius / 2.f));
	controlPoint2.x = (round(resolution * controlPoint2.x + alignStroke) - alignStroke) / resolution;
	controlPoint2.y = (round(resolution * controlPoint2.y + alignStroke) - alignStroke) / resolution;
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(0.0, (self.bounds.size.height - self.cornerRadius));
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(self.cornerRadius, self.bounds.size.height - 0.5f);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	controlPoint1 = CGPointMake(0.0, (self.bounds.size.height - (self.cornerRadius / 2.f)));
	controlPoint1.x = (round(resolution * controlPoint1.x + alignStroke) - alignStroke) / resolution;
	controlPoint1.y = (round(resolution * controlPoint1.y + alignStroke) - alignStroke) / resolution;
	controlPoint2 = CGPointMake((self.cornerRadius / 2.f), self.bounds.size.height - 0.5f);
	controlPoint2.x = (round(resolution * controlPoint2.x + alignStroke) - alignStroke) / resolution;
	controlPoint2.y = (round(resolution * controlPoint2.y + alignStroke) - alignStroke) / resolution;
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake((self.bounds.size.width - self.cornerRadius), self.bounds.size.height - 0.5f);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	CGPathCloseSubpath(path);
    
    if (self.state == UIControlStateHighlighted)
        gradient = self.highlightGradient;
    else
        gradient = self.normalGradient;
    
	CGContextAddPath(context, path);
	CGContextSaveGState(context);
	CGContextEOClip(context);
	point = CGPointMake((self.bounds.size.width / 2.0), self.bounds.size.height - 0.5f);
	point2 = CGPointMake((self.bounds.size.width / 2.0), 0.0);
	CGContextDrawLinearGradient(context, gradient, point, point2, (kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation));
	CGContextRestoreGState(context);
	[self.strokeColor setStroke];
	CGContextSetLineWidth(context, stroke);
	CGContextSetLineCap(context, kCGLineCapSquare);
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);
    
}
#pragma mark -
#pragma mark Touch Handling
- (void)hesitateUpdate
{
    [self setNeedsDisplay];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self setNeedsDisplay];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self setNeedsDisplay];
    [self performSelector:@selector(hesitateUpdate) withObject:nil afterDelay:0.1];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self setNeedsDisplay];
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self setNeedsDisplay];
    [self performSelector:@selector(hesitateUpdate) withObject:nil afterDelay:0.1];
}



@end
