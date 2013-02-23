//
//  ChartViewCell.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 23/02/2013.
//
//

#import <UIKit/UIKit.h>
#import "HealthChartsViewPortrait.h"
#import "Constants.h"

typedef enum
{
    kCD4Chart = 0,
    kCD4PercentChart = 1,
    kViralLoadChart = 2
}
ChartType;

@interface ChartViewCell : UITableViewCell
@property (nonatomic, strong) HealthChartsViewPortrait * chartView;
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
             margin:(float)margin
             height:(float)height
             events:(NSDictionary *)events;

- (void)reloadChartViewWithEvents:(NSDictionary *)events;
- (void)selectChart:(ChartType)chart;
@end
