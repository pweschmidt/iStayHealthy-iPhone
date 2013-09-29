//
//  CalendarView.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 29/09/2013.
//
//

#import "CalendarView.h"
#import "NSDate+Extras.h"
#import "GeneralSettings.h"
#import "ChartSettings.h"
#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>

@interface CalendarView ()
@property (nonatomic, strong) NSDictionary *calendarDictionary;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) UIButton *selectedButton;
@end

@implementation CalendarView

+ (CalendarView *)calenderViewForDate:(NSDate *)date frame:(CGRect)frame
{
    CalendarView *view = [[CalendarView alloc] initWithFrame:frame];
    view.date = date;
    view.calendarDictionary = [Utilities calendarDictionary];
    view.selectedButton = nil;
    UILabel *title = [view monthLabel];
    [view addSubview:title];
    UIView *weekDays = [view weekDayView];
    [view addSubview:weekDays];
    UIView *calendarView = [view calendarDayView];
    [view addSubview:calendarView];
    return view;
}


+ (CalendarView *)calendarViewForMonth:(NSUInteger)month
                                   day:(NSUInteger)day
                                 frame:(CGRect)frame
{
    CalendarView *view = [[CalendarView alloc] initWithFrame:frame];
    view.calendarDictionary = [Utilities calendarDictionary];
    view.selectedButton = nil;
    UILabel *title = [view monthLabel];
    [view addSubview:title];
    UIView *weekDays = [view weekDayView];
    [view addSubview:weekDays];
    UIView *calendarView = [view calendarDayView];
    [view addSubview:calendarView];
    return view;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UILabel *)monthLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, 18)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:15];
    label.text = [Utilities monthForDate:self.date];
    label.textColor = TEXTCOLOUR;
    return label;
}

- (UIView *)weekDayView
{
    __block UIView *view = [[UIView alloc]
                            initWithFrame:CGRectMake(self.bounds.origin.x + 20, self.bounds.origin.y + 20, self.bounds.size.width - 40, 18)];
    
    NSArray *days = [self.calendarDictionary objectForKey:@"shortDays"];
    CGFloat width = view.frame.size.width/7;
    CGFloat height = 18;
    CGFloat xOffset = view.frame.origin.x;
    CGFloat yOffset = view.frame.origin.y;
    [days enumerateObjectsUsingBlock:^(NSString *day, NSUInteger index, BOOL *stop) {
        CGRect labelFrame = CGRectMake(index * width + xOffset, yOffset, width, height);
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
        label.backgroundColor = [UIColor clearColor];
        label.text = day;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = TEXTCOLOUR;
        [view addSubview:label];
    }];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UIView *)calendarDayView
{
    NSMutableDictionary *diaryDictionary = [NSMutableDictionary dictionary];
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    view.frame = CGRectMake(self.bounds.origin.x + 20, self.bounds.origin.y + 60, self.bounds.size.width - 40, 100);
    NSDateComponents *components = [Utilities dateComponentsForDate:self.date];
    NSUInteger startDay = components.day;
    NSUInteger startWeekDay = components.weekday - 1;
    NSUInteger daysInMonth = [self.date daysInMonth];
    NSUInteger weeks = 0;
    CGFloat width = view.frame.size.width/7;
    CGFloat height = 20;
    
    for (NSUInteger day = startDay; day <= daysInMonth; day++)
    {
        if (6 < startWeekDay)
        {
            startWeekDay = 0;
            weeks++;
        }
        CGFloat xOffset = startWeekDay * width;
        CGFloat yOffset = weeks * height;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(xOffset, yOffset, width, height);
        button.backgroundColor = [UIColor clearColor];
        button.tag = day;
        [button addTarget:self action:@selector(checkIfMissed:) forControlEvents:UIControlEventTouchUpInside];
        CGFloat labelXOffset = (width - 20)/2;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelXOffset, 0, 20, 20)];
        label.backgroundColor = [UIColor clearColor];
        label.text = [NSString stringWithFormat:@"%d",day];
        label.textColor = [UIColor darkGrayColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15];
        label.layer.cornerRadius = 10;
        [button addSubview:label];
        [diaryDictionary setObject:button forKey:[NSNumber numberWithUnsignedInteger:day]];
        
        [view addSubview:button];
        startWeekDay++;
    }
    
    self.diary = (NSDictionary *)diaryDictionary;
    
    return view;
}

- (IBAction)checkIfMissed:(id)sender
{
    if (![sender isKindOfClass:[UIButton class]])
    {
        return;
    }
    self.selectedButton = (UIButton *)sender;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Medication", nil) message:NSLocalizedString(@"Did you take your meds?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Yes", nil) otherButtonTitles:NSLocalizedString(@"No", nil), nil];
    [alert show];
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (nil == self.selectedButton)
    {
        return;
    }
    NSArray *subviews = [self.selectedButton subviews];
    UILabel *label = nil;
    for (id subview in subviews)
    {
        if ([subview isKindOfClass:[UILabel class]])
        {
            label = (UILabel *)subview;
        }
    }
    if (nil == label)
    {
        return;
    }
    if (buttonIndex == alertView.cancelButtonIndex)
    {
        label.layer.backgroundColor = DARK_GREEN.CGColor;
        label.textColor = [UIColor whiteColor];
    }
    else
    {
        label.layer.backgroundColor = DARK_RED.CGColor;
        label.textColor = [UIColor whiteColor];
    }
    self.selectedButton = nil;
}

@end
