//
//  PWESAxis.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 14/10/2013.
//
//

#import "PWESAxis.h"
#import "PWESUtils.h"

@interface PWESAxis ()
{
    CGRect axisFrame;
}
@property (nonatomic, strong) PWESValueRange *valueRange;
@end

@implementation PWESAxis

- (id)initVerticalAxisWithFrame:(CGRect)frame
                     valueRange:(PWESValueRange *)valueRange
                    orientation:(AxisType)orientation
                          ticks:(CGFloat)ticks
{
    self = [super init];
    if (nil != self)
    {
        _orientation = orientation;
        _axisLayer = [CALayer layer];
        _axisLayer.frame = frame;
        _valueRange = valueRange;
        _ticks = ticks;
    }
    return self;
}

- (id)initHorizontalAxisWithFrame:(CGRect)frame
{
    self = [super init];
    if (nil != self)
    {
        _orientation = Horizontal;
        _axisLayer = [CALayer layer];
        _axisLayer.frame = frame;
        _valueRange = nil;
        _ticks = 0;
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
    if (Vertical == self.orientation)
    {
        axisStart = CGPointMake(frame.origin.x + frame.size.width/2 + kAxisLineWidth/2, frame.origin.y);
        axisEnd = CGPointMake(frame.origin.x + frame.size.width/2 + kAxisLineWidth/2, frame.size.height);
        [self addTickMarks:context frame:frame];
        [self addLabels:context frame:frame];
    }
    else
    {
        axisStart = CGPointMake(frame.origin.x + kAxisLineWidth/2, frame.origin.y + frame.size.height/2 - kAxisLineWidth/2);
        axisEnd = CGPointMake(frame.size.width, frame.origin.y + frame.size.height/2 - kAxisLineWidth/2);
    }
    [self drawLineWithContext:context start:axisStart end:axisEnd lineWidth:kAxisLineWidth cgColour:self.axisColor.CGColor];
}

- (void)addTickMarks:(CGContextRef)context frame:(CGRect)frame
{
    CGFloat yOffset = frame.origin.y + kPXTickDistance;
    CGFloat xStart = frame.origin.x + frame.size.width/2 + kAxisLineWidth/2 - kTickLength/2;
    CGFloat xEnd = xStart + kTickLength;
    
    for (int tick = 0; tick < self.ticks; tick++)
    {
        CGPoint start = CGPointMake(xStart, yOffset);
        CGPoint end = CGPointMake(xEnd, yOffset);
        [self drawLineWithContext:context start:start end:end lineWidth:kAxisTickWidth cgColour:self.axisColor.CGColor];
        yOffset += kPXTickDistance;
    }
}

- (void)addLabels:(CGContextRef)context frame:(CGRect)frame
{
    
}

@end
