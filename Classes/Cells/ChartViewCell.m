//
//  ChartViewCell.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 23/02/2013.
//
//

#import "ChartViewCell.h"
#import "GeneralSettings.h"
#import "ChartSettings.h"

@implementation ChartViewCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
             margin:(float)margin
             height:(float)height
             events:(NSDictionary *)events
{
    self = [self initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (nil != self)
    {
        CGRect frame = CGRectMake(CGRectGetMinX(self.bounds)+margin/2, CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds) - margin*1.5, height-5.0);
        self.chartView = [[HealthChartsViewPortrait alloc] initWithFrame:frame events:events];
        self.backgroundColor = BRIGHT_BACKGROUND;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.chartView];
    }
    return self;
}

- (void)reloadChartViewWithEvents:(NSDictionary *)events
{
    if (self.chartView && events)
    {
        [self.chartView loadEvents:events];
        [self.chartView setNeedsDisplay];
    }
}

- (void)selectChart:(ChartType)chart
{
    switch (chart)
    {
        case kCD4Chart:
            [self.chartView showCD4];
            break;
        case kCD4PercentChart:
            [self.chartView showCD4Percent];
            break;
        case kViralLoadChart:
            [self.chartView showViralLoad];
            break;
    }
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
