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
@end

@implementation PWESAxis

- (id)initWithFrame:(CGRect)frame
        orientation:(AxisType)orientation
{
    self = [super init];
    if (nil != self)
    {
        _orientation = orientation;
        _lineWidth = 2.0;
        _tickWidth = 1.0;
        _pxTickDistance = 25.0;
        _axisLayer = [CALayer layer];
        _axisLayer.frame = frame;
        _tickLength = 10;
    }
    return self;;
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
        axisStart = CGPointMake(frame.origin.x + frame.size.width/2 + self.lineWidth/2, frame.origin.y);
        axisEnd = CGPointMake(frame.origin.x + frame.size.width/2 + self.lineWidth/2, frame.size.height);
        [self addTickMarks:context frame:frame];
    }
    else
    {
        axisStart = CGPointMake(frame.origin.x + self.lineWidth/2, frame.origin.y + frame.size.height/2 - self.lineWidth/2);
        axisEnd = CGPointMake(frame.size.width, frame.origin.y + frame.size.height/2 - self.lineWidth/2);
    }
    [self drawLineWithContext:context start:axisStart end:axisEnd lineWidth:self.lineWidth cgColour:self.axisColor.CGColor];
}

- (void)addTickMarks:(CGContextRef)context frame:(CGRect)frame
{
    CGFloat yOffset = frame.origin.y + self.pxTickDistance;
    CGFloat xStart = frame.origin.x + frame.size.width/2 + self.lineWidth/2 - self.tickLength/2;
    CGFloat xEnd = xStart + self.tickLength;
    
    int ticks = roundf(frame.size.height / self.pxTickDistance);
    for (int tick = 0; tick < ticks; tick++)
    {
        CGPoint start = CGPointMake(xStart, yOffset);
        CGPoint end = CGPointMake(xEnd, yOffset);
        [self drawLineWithContext:context start:start end:end lineWidth:self.tickWidth cgColour:self.axisColor.CGColor];
        yOffset += self.pxTickDistance;
    }
}

@end
