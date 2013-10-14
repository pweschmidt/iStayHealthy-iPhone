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
        _pxTickDistance = 25.0;
        _axisLayer = [CALayer layer];
        _axisLayer.frame = frame;
//        _axisLayer.backgroundColor = [UIColor whiteColor].CGColor;
    }
    return self;;
}


- (void)show
{
    if (nil == self.axisLayer)
    {
        return;
    }
    self.axisLayer.delegate = self;
    [self.axisLayer setNeedsDisplay];
}

- (void)drawLayer:(CALayer *)layer
        inContext:(CGContextRef)context
{
    CGPoint axisStart;
    CGPoint axisEnd;
    
    CGRect frame = self.axisLayer.frame;
    if (Vertical == self.orientation)
    {
        axisStart = CGPointMake(frame.origin.x + frame.size.width/2 + self.lineWidth/2, frame.origin.y);
        axisEnd = CGPointMake(frame.origin.x + frame.size.width/2 + self.lineWidth/2, frame.size.height);
//        [self addTickMarks];
    }
    else
    {
        axisStart = CGPointMake(frame.origin.x, frame.origin.y + frame.size.height/2 - self.lineWidth/2);
        axisEnd = CGPointMake(frame.size.width, frame.origin.y + frame.size.height/2 - self.lineWidth/2);
    }
//    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, self.axisColor.CGColor);
    CGContextSetLineWidth(context, self.lineWidth);
    CGFloat lineOffset = self.lineWidth / 2;
    CGContextMoveToPoint(context, axisStart.x + lineOffset, axisStart.y + lineOffset);
    CGContextAddLineToPoint(context, axisEnd.x + lineOffset, axisEnd.y + lineOffset);
    CGContextStrokePath(context);
//    CGContextRestoreGState(context);

    /*
    [[PWESUtils sharedInstance] drawLineWithContext:ctx start:axisStart end:axisEnd lineWidth:self.lineWidth cgColour:self.axisColor.CGColor];
     */
}

- (void)addTickMarks
{
    
}

@end
