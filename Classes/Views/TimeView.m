//
//  TimeView.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/10/2013.
//
//

#import "TimeView.h"

@interface TimeView ()
{
    CGRect timeFrame;
}
@property (nonatomic, strong) NSDate *time;
@end

@implementation TimeView

+ (TimeView *)viewWithTime:(NSDate *)date
                     frame:(CGRect)frame
{
    TimeView *view = [[TimeView alloc] initWithFrame:frame];
    view.time = date;
    return view;
}

@end
