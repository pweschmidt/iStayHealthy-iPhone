//
//  PWESDashboardSummaryView.m
//  HealthCharts
//
//  Created by Peter Schmidt on 20/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import "PWESDashboardSummaryView.h"
#import "PWESResultsSummaryView.h"
#import "PWESDataTuple.h"

@implementation PWESDashboardSummaryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (PWESDashboardSummaryView *)summaryViewWithFrame:(CGRect)frame
                                            nTuple:(PWESDataNTuple *)nTuple
                                       medications:(NSArray *)medications
                                             types:(NSArray *)types
{
    PWESDashboardSummaryView *summaryView = [[PWESDashboardSummaryView alloc] initWithFrame:frame];
    [summaryView buildSummaryViewForNTuple:nTuple medications:medications types:types];
    return summaryView;
    
}

- (void)buildSummaryViewForNTuple:(PWESDataNTuple *)nTuple
                      medications:(NSArray *)medications
                            types:(NSArray *)types
{
    if (nil == nTuple || nil == medications || nil == types || 0 == types.count)
    {
        return;
    }
    CGFloat componentWidth = self.bounds.size.width;
    CGFloat componentHeight = self.bounds.size.height;
    CGFloat xOrigin = self.bounds.origin.x;
    CGFloat yOrigin = self.bounds.origin.y;
    if (1 < types.count)
    {
        componentHeight = componentHeight / types.count;
    }
    NSUInteger index = 0;
    for (NSString *type in types)
    {
        PWESDataTuple *tuple = [nTuple tupleForType:type];
        CGFloat y = yOrigin + index * (componentHeight/types.count);
        CGRect frame = CGRectMake(xOrigin, y, componentWidth, componentHeight);
        PWESResultsSummaryView *resultsView = [PWESResultsSummaryView
                                               resultsSummaryViewWithFrame:frame
                                               dataTuple:tuple
                                               medications:medications];
        [self addSubview:resultsView];
        index++;
    }
}

@end
