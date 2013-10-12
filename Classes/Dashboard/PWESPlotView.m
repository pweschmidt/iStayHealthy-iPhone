//
//  PWESPlotView.m
//  HealthCharts
//
//  Created by Peter Schmidt on 13/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import "PWESPlotView.h"
#import <QuartzCore/QuartzCore.h>

@interface PWESPlotView ()
{
    CGRect plotBoundaries;
}
@property (nonatomic, strong) NSArray *types;
@property (nonatomic, strong) PWESDataNTuple *ntuple;
@property (nonatomic, strong) NSArray *medications;
@end

@implementation PWESPlotView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _marginBottom = _marginLeft = _marginRight = _marginTop = 20;
    }
    return self;
}

+ (PWESPlotView *)plotViewWithFrame:(CGRect)frame
                             nTuple:(PWESDataNTuple *)nTuple
                        medications:(NSArray *)medications
                              types:(NSArray *)types
{
    PWESPlotView *plotView = [[PWESPlotView alloc] initWithFrame:frame];
    plotView.ntuple = nTuple;
    plotView.medications = medications;
    plotView.types = types;
    [plotView configurePlotView];
    return plotView;
}

- (void)configurePlotView
{
    self.layer.delegate = self;
    plotBoundaries = CGRectMake(self.marginLeft, self.bounds.size.height - self.marginBottom, self.bounds.size.width - self.marginLeft - self.marginRight, self.bounds.size.height - self.marginBottom - self.marginTop);
    self.backgroundColor = [UIColor whiteColor];
    [self addVerticalAxis];
    [self addHorizontalAxis];
    if (2 == self.types.count)
    {
        [self addVerticalRightAxis];
    }
//    [self.layer setNeedsDisplay];
}


- (void)addHorizontalAxis
{
    CALayer *axis = [CALayer layer];
    axis.frame = CGRectMake(plotBoundaries.origin.x, plotBoundaries.origin.y, plotBoundaries.size.width, 2);
    axis.backgroundColor = [UIColor blackColor].CGColor;
    [self.layer addSublayer:axis];
}

- (void)addVerticalRightAxis
{
    CALayer *axis = [CALayer layer];
    axis.frame = CGRectMake(plotBoundaries.origin.x + plotBoundaries.size.width - 2, self.marginTop, 2, plotBoundaries.size.height);
    axis.backgroundColor = [UIColor blackColor].CGColor;
    [self.layer addSublayer:axis];
}


- (void)addVerticalAxis
{
    CALayer *axis = [CALayer layer];
    axis.frame = CGRectMake(plotBoundaries.origin.x, self.marginTop, 2, plotBoundaries.size.height);
    axis.backgroundColor = [UIColor blackColor].CGColor;
    [self.layer addSublayer:axis];
}




- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
//    layer.backgroundColor = [UIColor clearColor].CGColor;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
