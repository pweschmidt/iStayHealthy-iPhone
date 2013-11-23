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
#import "PWESValueRange.h"
#import "GeneralSettings.h"
#import "Constants.h"
#import "UIFont+Standard.h"
#import <QuartzCore/QuartzCore.h>

@interface PWESPlotView ()
{
    CGRect plotBoundaries;
    CGFloat ticks;
}
@property (nonatomic, strong) PWESAxis *xAxis;
@property (nonatomic, strong) PWESAxis *yAxis;
@property (nonatomic, strong) PWESAxis *yAxisRight;
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
    plotView.pxTickDistance = kPXTickDistance;
    plotView.ntuple = nTuple;
    plotView.medications = medications;
    plotView.types = types;
    [plotView configurePlotView];
    return plotView;
}

- (void)configurePlotView
{
    if (self.ntuple.isEmpty)
    {
        UILabel *emptyLabel = [[UILabel alloc] init];
        emptyLabel.frame = CGRectMake(self.bounds.origin.x + self.bounds.size.width/2 - 100, self.bounds.origin.y + self.bounds.size.height/2 - 50 , 200, 100);
        emptyLabel.backgroundColor = [UIColor clearColor];
        emptyLabel.textAlignment = NSTextAlignmentCenter;
        emptyLabel.textColor = TEXTCOLOUR;
        emptyLabel.font = [UIFont fontWithType:Light size:20];
        emptyLabel.text = NSLocalizedString(@"No results available", nil);
        [self addSubview:emptyLabel];
        return;
    }
    
    
    CGRect yAxisFrame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.marginLeft * 2, self.bounds.size.height - self.marginBottom);

    ticks = roundf(yAxisFrame.size.height / self.pxTickDistance);
    
    CGRect xAxisFrame = CGRectMake(self.bounds.origin.x+self.marginLeft, self.bounds.size.height - self.marginBottom - self.marginTop, self.bounds.size.width - self.marginRight - self.marginLeft, self.marginBottom * 2);


    PWESDataTuple *dataTuple = [self.ntuple tupleForType:[self.types objectAtIndex:0]];
    PWESValueRange *rangeLeft = [PWESValueRange valueRangeForDataTuple:dataTuple ticks:ticks];
    
    
    self.yAxis = [[PWESAxis alloc] initVerticalAxisWithFrame:yAxisFrame
                                                  valueRange:rangeLeft
                                                 orientation:Vertical
                                                       ticks:ticks];
    if (self.yAxis.axisLayer)
    {
        [self.layer addSublayer:self.yAxis.axisLayer];
        [self.yAxis show];
    }
    self.xAxis = [[PWESAxis alloc] initHorizontalAxisWithFrame:xAxisFrame];
    if (self.xAxis)
    {
        [self.layer addSublayer:self.xAxis.axisLayer];
        [self.xAxis show];
    }
    if (2 == self.types.count)
    {
        PWESDataTuple *dataTupleRight = [self.ntuple tupleForType:[self.types objectAtIndex:1]];
        PWESValueRange *rangeRight = [PWESValueRange valueRangeForDataTuple:dataTupleRight ticks:ticks];
        CGRect yAxisFrameRight = CGRectMake(self.bounds.origin.x + self.bounds.size.width - self.marginRight - self.marginLeft - 3, self.bounds.origin.y, self.marginLeft * 2, self.bounds.size.height - self.marginBottom);
        self.yAxisRight = [[PWESAxis alloc] initVerticalAxisWithFrame:yAxisFrameRight
                                                           valueRange:rangeRight
                                                          orientation:Vertical
                                                                ticks:ticks];
        if (self.yAxisRight.axisLayer)
        {
            [self.layer addSublayer:self.yAxisRight.axisLayer];
            [self.yAxisRight show];
        }
    }
    
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
