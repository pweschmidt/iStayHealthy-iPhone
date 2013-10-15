//
//  PWESPlotArea.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 15/10/2013.
//
//

#import "PWESPlotArea.h"

@implementation PWESPlotArea

- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (nil != self)
    {
        _lineWidth = 2.0;
        _plotLayer = [CALayer layer];
        _plotLayer.frame = frame;
    }
    return self;
}

- (void)showNoData
{
    
}

- (void)show
{
    if (nil == self.plotLayer)
    {
        return;
    }
    if (nil == self.plotLayer.delegate)
    {
        self.plotLayer.delegate = self;
    }
    [self.plotLayer setNeedsDisplay];
}

- (void)drawLayer:(CALayer *)layer
        inContext:(CGContextRef)ctx
{
    
}

@end
