//
//  PWESDashboardView.m
//  HealthCharts
//
//  Created by Peter Schmidt on 20/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import "PWESDashboardView.h"
#import "PWESDashboardSummaryView.h"
#import "PWESPlotView.h"
#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>

@implementation PWESDashboardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
    }
    return self;
}

+ (PWESDashboardView *)dashboardViewWithFrame:(CGRect)frame
                                       nTuple:(PWESDataNTuple *)nTuple
                                        types:(PWESResultsTypes *)types
{
    PWESDashboardView *dashboard = [[PWESDashboardView alloc] initWithFrame:frame];

    [dashboard buildDashboardViewWithNTuple:nTuple types:types];
    return dashboard;
}

- (void)buildDashboardViewWithNTuple:(PWESDataNTuple *)nTuple
                               types:(PWESResultsTypes *)types
{
    self.layer.cornerRadius = 20;
    self.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.layer.borderWidth = 1;
    self.backgroundColor = [UIColor whiteColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;


//    NSLog(@"*** DASHBOARD FOR %@ ****",types);
//    NSLog(@"*** FRAME x=%3.2f y=%3.2f width=%3.2f height=%3.2f",self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
//    NSLog(@"*** BOUNDS x=%3.2f y=%3.2f width=%3.2f height=%3.2f",self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
    CGFloat margin = ([Utilities isIPad]) ? kPlotMarginiPad : kPlotMarginiPhone;

    CGRect summary = CGRectMake(self.bounds.origin.x + margin, self.bounds.origin.y + 5, self.bounds.size.width - 2 * margin, kSummaryViewHeight);
    PWESDashboardSummaryView *summaryView = [PWESDashboardSummaryView
                                             summaryViewWithFrame:summary
                                                           nTuple:nTuple
                                                            types:types];


    [self addSubview:summaryView];

    CGRect plotFrame = CGRectMake(self.bounds.origin.x + margin, self.bounds.origin.y + 5 + kSummaryViewHeight, self.bounds.size.width - 2 * margin, self.bounds.size.height - kSummaryViewHeight - 10);

    PWESPlotView *plot = [PWESPlotView plotViewWithFrame:plotFrame
                                                  nTuple:nTuple
                                                   types:types];
    if (nil != plot)
    {
//		[plot show];
        [self addSubview:plot];
    }
}

@end
