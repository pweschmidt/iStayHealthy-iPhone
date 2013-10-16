//
//  PWESResultsSummaryView.m
//  HealthCharts
//
//  Created by Peter Schmidt on 20/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import "PWESResultsSummaryView.h"
#import "Constants.h"
#import "PWESChartsConstants.h"
#import "PWESUtils.h"
#import "PWESIndicatorView.h"
#import "Results.h"
#import "Utilities.h"
#import "UIFont+Standard.h"
@implementation PWESResultsSummaryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (PWESResultsSummaryView *)resultsSummaryViewWithFrame:(CGRect)frame
                                              dataTuple:(PWESDataTuple *)dataTuple
                                            medications:(NSArray *)medications
{
    PWESResultsSummaryView *resultsSummaryView = [[PWESResultsSummaryView alloc]
                                                  initWithFrame:frame];
    [resultsSummaryView buildResultsSummaryViewForTuple:dataTuple medications:medications];
    return resultsSummaryView;
}


- (void)buildResultsSummaryViewForTuple:(PWESDataTuple *)tuple medications:(NSArray *)medications
{
    CGFloat marginX = 20;
    CGFloat margin  = 0;
    CGFloat totalHeight     = self.bounds.size.height;
    CGFloat componentWidth = (self.bounds.size.width - marginX )/ 3;

    CGFloat titleOffsetX        = marginX;
    CGFloat valueOffsetX        = titleOffsetX + componentWidth;
    CGFloat indicatorOffsetX    = valueOffsetX + componentWidth;
    CGFloat yOffset             = margin;
    CGRect titleRect            = CGRectMake(titleOffsetX, yOffset, componentWidth, totalHeight);
    CGRect valueRect            = CGRectMake(valueOffsetX, yOffset, componentWidth, totalHeight);
    CGRect indicatorFrame       = CGRectMake(indicatorOffsetX, yOffset + 10, componentWidth-10, totalHeight - 20);
    
    
    UIFont *font = [UIFont fontWithType:Bold size:13];
    
    UIView *titleView           = [[UIView alloc] initWithFrame:titleRect];
    titleView.backgroundColor   = [UIColor clearColor];
    
    UILabel *titleLabel         = [[UILabel alloc] initWithFrame:CGRectMake(titleView.bounds.origin.x, titleView.bounds.origin.y, titleView.bounds.size.width, titleView.bounds.size.height)];
    titleLabel.backgroundColor  = [UIColor clearColor];
    titleLabel.font             = font;
    NSDictionary *typeDictionary = [Utilities resultsTypeDictionary];
    titleLabel.text             = [typeDictionary objectForKey:tuple.type];
    [titleView addSubview:titleLabel];
    NSDictionary *colourDictionary = [Utilities colourTypeDictionary];
    titleLabel.textColor        = [colourDictionary objectForKey:tuple.type];
    [self addSubview:titleView];
    
    UIView *valueView           = [[UIView alloc] initWithFrame:valueRect];
    valueView.backgroundColor   = [UIColor clearColor];
    UILabel *valueLabel         = [[UILabel alloc] initWithFrame:CGRectMake(valueView.bounds.origin.x, valueView.bounds.origin.y, valueView.bounds.size.width, valueView.bounds.size.height)];
    valueLabel.backgroundColor  = [UIColor clearColor];
    valueLabel.font             = font;

    if (0 == tuple.valueTuple.count)
    {
        valueLabel.text = @"";
    }
    else
    {
        NSNumber *lastValue = [tuple.valueTuple lastObject];
        float value = [lastValue floatValue];
        if ([tuple.type isEqualToString:kViralLoad] && 1 == value)
        {
            valueLabel.text = @"undetectable";
        }
        else
        {
            valueLabel.text = [PWESIndicatorView valueStringForValue:[lastValue floatValue]
                                                                type:tuple.type
                                                         hasPlusSign:NO];
        }
    }
    
    [valueView addSubview:valueLabel];
    [self addSubview:valueView];
    
    
    PWESIndicatorView *indicator = [PWESIndicatorView initWithFrame:indicatorFrame tupel:tuple];
    [self addSubview:indicator];
}
@end
