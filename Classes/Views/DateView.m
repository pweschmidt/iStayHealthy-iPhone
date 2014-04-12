//
//  DateView.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 22/09/2013.
//
//

#import "DateView.h"
#import "GeneralSettings.h"
@interface DateView ()
{
    CGRect yearFrame;
    CGRect yearLabelFrame;
    CGRect monthFrame;
    CGRect dayFrame;
    CGFloat yearFontSize;
    CGFloat dayFontSize;
    CGFloat monthFontSize;
}
@property (nonatomic, strong) NSDate *date;
@end

@implementation DateView

+ (DateView *)viewWithDate:(NSDate *)date
                     frame:(CGRect)frame
{
    DateView *view = [[DateView alloc] initWithFrame:frame];
    view.date = date;
    [view drawDateLabels];
    return view;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self configureFrames];
    }
    return self;
}

/**
 the year label is 1/4 of the total width
 the month label is 2/3 of the height of the cell
 the day label is 1/3 of the cell height
 */
- (void)configureFrames
{
//    self.layer.cornerRadius = 5;
//    self.layer.borderColor = [UIColor blueColor].CGColor;
//    self.layer.borderWidth = 1;
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    
    CGFloat yearWidth = width/4;
    
    yearFrame = CGRectMake(0, 0, yearWidth, height);
    CGFloat yearLabelWidth = height;
    CGFloat yearLabelHeight = yearWidth;
    CGFloat yearLabelXOffset = 0 - yearLabelWidth/2 + yearLabelHeight/2;
    CGFloat yearLabelYOffset = yearLabelWidth/2 - yearLabelHeight/2;
    
    yearLabelFrame = CGRectMake(yearLabelXOffset, yearLabelYOffset, yearLabelWidth, yearLabelHeight);
    yearFontSize = yearLabelHeight - 1;
    
    CGFloat xOffset = yearWidth;
    CGFloat lWidth = width - yearWidth;
    CGFloat dayHeight = height * 2 / 3;
    CGFloat monthHeight = height / 3;
    
    dayFrame = CGRectMake(xOffset, 0, lWidth, dayHeight);
    dayFontSize = dayHeight * 0.9;
    monthFrame = CGRectMake(xOffset, dayHeight, lWidth, monthHeight);
    monthFontSize = monthHeight - 1;
}

- (void)drawDateLabels
{
    [self addSubview:[self yearPanel]];
    [self addSubview:[self monthPanel]];
    [self addSubview:[self dayPanel]];
}

- (UIView *)yearPanel
{
    NSDateComponents *components = [[NSCalendar currentCalendar]
                                    components:NSYearCalendarUnit
                                    fromDate:self.date];
    int year = (int)[components year];
    
    UIView *view = [[UIView alloc] init];
    view.frame = yearFrame;
    UILabel *label = [[UILabel alloc] init];
    label.frame = yearLabelFrame;
    label.backgroundColor = [UIColor lightGrayColor];
    label.text = [NSString stringWithFormat:@"%d",year];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:yearFontSize];
    label.textColor = [UIColor whiteColor];
    label.transform = CGAffineTransformMakeRotation(-(M_PI)/2);
    [label.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
    [view addSubview:label];
    return view;
}

- (UIView *)dayPanel
{
    NSDateComponents *components = [[NSCalendar currentCalendar]
                                    components: NSDayCalendarUnit
                                    fromDate:self.date];
    int day = (int)[components day];
    UIView *view = [[UIView alloc] init];
    view.frame = dayFrame;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, dayFrame.size.width, dayFrame.size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.text = [NSString stringWithFormat:@"%d",day];
    if (9 < day)
    {
        label.textAlignment = NSTextAlignmentRight;
    }
    else
    {
        label.textAlignment = NSTextAlignmentCenter;
    }
    label.textColor = [UIColor darkGrayColor];
    label.font = [UIFont boldSystemFontOfSize:dayFontSize];
    [view addSubview:label];
    return view;
}

- (UIView *)monthPanel
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM"];
    NSString *month = [dateFormatter stringFromDate:self.date];
    UIView *view = [[UIView alloc] init];
    view.frame = monthFrame;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, monthFrame.size.width, monthFrame.size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:monthFontSize];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor darkGrayColor];
    label.text = [NSString stringWithFormat:@"%@",month];
    [view addSubview:label];
    return view;
}
@end
