//
//  PWESPlotView.m
//  HealthCharts
//
//  Created by Peter Schmidt on 13/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import "PWESPlotView.h"
#import "PWESAxis.h"
#import "PWESChartsConstants.h"
#import <QuartzCore/QuartzCore.h>

@interface PWESPlotView ()
{
    CGRect plotBoundaries;
    int ticks;
}
@property (nonatomic, strong) PWESAxis *xAxis;
@property (nonatomic, strong) PWESAxis *yAxis;
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
    plotView.pxTickDistance = 25;
    plotView.ntuple = nTuple;
    plotView.medications = medications;
    plotView.types = types;
    [plotView configurePlotView];
    return plotView;
}

- (void)configurePlotView
{
//    self.layer.backgroundColor = [UIColor blueColor].CGColor;
    CGRect yAxisFrame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.marginLeft * 2, self.bounds.size.height - self.marginBottom);

    CGRect xAxisFrame = CGRectMake(self.bounds.origin.x+self.marginLeft, self.bounds.size.height - self.marginBottom - self.marginTop, self.bounds.size.width - self.marginRight - self.marginLeft, self.marginBottom * 2);
    self.yAxis = [[PWESAxis alloc] initWithFrame:yAxisFrame orientation:Vertical];
    if (self.yAxis.axisLayer)
    {
//        self.yAxis.axisLayer.backgroundColor = [UIColor redColor].CGColor;
        [self.layer addSublayer:self.yAxis.axisLayer];
        [self.yAxis show];
    }
    self.xAxis = [[PWESAxis alloc] initWithFrame:xAxisFrame orientation:Horizontal];
    if (self.xAxis)
    {
//        self.xAxis.axisLayer.backgroundColor = [UIColor greenColor].CGColor;
        [self.layer addSublayer:self.xAxis.axisLayer];
        [self.xAxis show];
    }
    
    /*
    self.layer.delegate = self;
    plotBoundaries = CGRectMake(self.marginLeft, self.bounds.size.height - self.marginBottom, self.bounds.size.width - self.marginLeft - self.marginRight, self.bounds.size.height - self.marginBottom - self.marginTop);
    self.backgroundColor = [UIColor whiteColor];
    ticks = floorf(plotBoundaries.size.height / self.pxTickDistance);
    [self addVerticalAxis];
    [self addHorizontalAxis];
    if (2 == self.types.count)
    {
        [self addVerticalRightAxis];
    }
     */
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




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


@end
