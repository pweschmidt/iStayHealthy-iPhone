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
#import <QuartzCore/QuartzCore.h>

@implementation PWESDashboardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (PWESDashboardView* )dashboardViewWithFrame:(CGRect) frame
                                       nTuple:(PWESDataNTuple *)nTuple
                                  medications:(NSArray *)medications
                                        types:(NSArray *)types
{
    PWESDashboardView *dashboard = [[PWESDashboardView alloc] initWithFrame:frame];
    [dashboard buildDashboardViewWithNTuple:nTuple medications:medications types:types];
    return dashboard;
}

- (void)buildDashboardViewWithNTuple:(PWESDataNTuple *)nTuple
                         medications:(NSArray *)medications
                               types:(NSArray *)types
{
    self.layer.cornerRadius = 20;
    self.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.layer.borderWidth = 1;
    self.backgroundColor = [UIColor whiteColor];
    
    
//    NSLog(@"*** DASHBOARD FOR %@ ****",types);
//    NSLog(@"*** FRAME x=%3.2f y=%3.2f width=%3.2f height=%3.2f",self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
//    NSLog(@"*** BOUNDS x=%3.2f y=%3.2f width=%3.2f height=%3.2f",self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
    
    CGRect summary = CGRectMake(self.bounds.origin.x, self.bounds.origin.y + 5, self.bounds.size.width, kSummaryViewHeight);
    PWESDashboardSummaryView *summaryView = [PWESDashboardSummaryView
                                             summaryViewWithFrame:summary
                                             nTuple:nTuple
                                             medications:medications
                                             types:types];
    
    
    [self addSubview:summaryView];

    CGRect plotFrame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y + 5 + kSummaryViewHeight, self.bounds.size.width, self.bounds.size.height - kSummaryViewHeight - 10);

    PWESPlotView *plot = [PWESPlotView plotViewWithFrame:plotFrame
                                                  nTuple:nTuple
                                             medications:medications
                                                   types:types];


    [self addSubview:plot];
}


@end
