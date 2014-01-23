//
//  CalendarMonthView.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/01/2014.
//
//

#import "CalendarMonthView.h"
#import "NSDate+Extras.h"
#import "GeneralSettings.h"
#import "ChartSettings.h"
#import "Utilities.h"
#import "UIFont+Standard.h"
#import "Constants.h"
#import "SeinfeldCalendar.h"
#import "SeinfeldCalendarEntry.h"
#import "CoreDataManager.h"
#import <QuartzCore/QuartzCore.h>

@interface CalendarMonthView ()
{
    CGFloat titleHeight;
    CGFloat weekDayTitleHeight;
    CGFloat weekDayValueHeight;
    CGFloat xOffset;
    CGFloat yOffset;
    CGFloat width;
    NSInteger weeks;
}
@property (nonatomic, strong) NSDateComponents *startComponents;
@property (nonatomic, strong) NSDateComponents *endComponents;
@property (nonatomic, strong) NSDateComponents *todayComponents;
@property (nonatomic, strong) NSMutableDictionary *dayButtonsMap;
@end

@implementation CalendarMonthView


+ (CalendarMonthView *)calendarMonthViewForCalendar:(SeinfeldCalendar *)calendar
                                    startComponents:(NSDateComponents *)startComponents
                                      endComponents:(NSDateComponents *)endComponents
                                     suggestedFrame:(CGRect)suggestedFrame
{
    CalendarMonthView *monthView = [[CalendarMonthView alloc] initWithFrame:suggestedFrame];
    monthView.todayComponents = [Utilities dateComponentsForDate:[NSDate date]];
    monthView.startComponents = startComponents;
    monthView.endComponents = endComponents;
    [monthView correctHeightFromDates];
    [monthView addHeaderView];
    [monthView addWeekHeaderView];
    [monthView addWeekRows];
    return monthView;
}

- (void)addHeaderView
{
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, self.bounds.origin.y, width, titleHeight)];
    NSLog(@"HEADER bounds x=%f y=%f w=%f h=%f ",header.bounds.origin.x,header.bounds.origin.y,header.bounds.size.width,header.bounds.size.height);
    NSLog(@"HEADER frame x=%f y=%f w=%f h=%f ",header.frame.origin.x,header.frame.origin.y,header.frame.size.width,header.frame.size.height);
    header.backgroundColor = [UIColor clearColor];
    header.textAlignment = NSTextAlignmentRight;
    header.font = [UIFont fontWithType:Bold size:standard];
    header.textColor = TEXTCOLOUR;
    NSArray *months = [[Utilities calendarDictionary] objectForKey:@"months"];
    int monthIndex = self.startComponents.month - 1;
    header.text = [NSString stringWithFormat:@"%@, %d", [months objectAtIndex:monthIndex], self.startComponents.year];
    [self addSubview:header];
}

- (void)addWeekHeaderView
{
    __block UIView *weekHeader = [[UIView alloc] initWithFrame:CGRectMake(xOffset, self.bounds.origin.y + yOffset, width, weekDayTitleHeight)];
    NSLog(@"WEEKHEADER bounds x=%f y=%f w=%f h=%f ",weekHeader.bounds.origin.x,weekHeader.bounds.origin.y,weekHeader.bounds.size.width,weekHeader.bounds.size.height);
    NSLog(@"WEEKHEADER frame x=%f y=%f w=%f h=%f ",weekHeader.frame.origin.x,weekHeader.frame.origin.y,weekHeader.frame.size.width,weekHeader.frame.size.height);
    NSArray *days = [[Utilities calendarDictionary] objectForKey:@"shortDays"];
    CGFloat weekDaywidth = weekHeader.frame.size.width/7;
    CGFloat weekDayX = weekHeader.bounds.origin.x + 20;
    CGFloat weekDayY = weekHeader.bounds.origin.y+3;
    [days enumerateObjectsUsingBlock:^(NSString *day, NSUInteger index, BOOL *stop) {
        CGRect labelFrame = CGRectMake(index * weekDaywidth + weekDayX, weekDayY, weekDaywidth, weekDayTitleHeight);
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
        label.backgroundColor = [UIColor clearColor];
        label.text = day;
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont fontWithType:Standard size:standard];
        label.textColor = TEXTCOLOUR;
        [weekHeader addSubview:label];
    }];
    weekHeader.backgroundColor = [UIColor clearColor];
    [self addSubview:weekHeader];
}


- (void)addWeekRows
{
    CGFloat heightOffset = self.bounds.origin.y + 3 + 2 * yOffset;
    UIView *weekRowView = [[UIView alloc] initWithFrame:CGRectMake(xOffset, heightOffset, width, weeks * yOffset)];
    NSLog(@"WEEK bounds x=%f y=%f w=%f h=%f ",weekRowView.bounds.origin.x,weekRowView.bounds.origin.y,weekRowView.bounds.size.width,weekRowView.bounds.size.height);
    NSLog(@"WEEK frame x=%f y=%f w=%f h=%f ",weekRowView.frame.origin.x,weekRowView.frame.origin.y,weekRowView.frame.size.width,weekRowView.frame.size.height);
    weekRowView.backgroundColor = [UIColor clearColor];
    NSUInteger startDay = self.startComponents.day;
    NSUInteger endDay = self.endComponents.day;
    NSInteger days = endDay - startDay + 1;

    
    NSUInteger startWeekDayIndex = self.startComponents.weekday - 1;
    NSUInteger weekIndex = 0;
    if (0 >= days)
    {
        days = 1;
    }
    CGFloat dayWidth = width/7;
    NSUInteger dayCounter = startDay;
    for (NSUInteger day = 0; day < days; ++day)
    {
        if (6 < startWeekDayIndex)
        {
            startWeekDayIndex = 0;
            weekIndex++;
        }
        CGFloat xDay = startWeekDayIndex * dayWidth;
        CGFloat yDay =  yOffset * weekIndex;
        CGRect buttonFrame = CGRectMake(xDay, yDay, dayWidth, yOffset);
        UIButton *dayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        dayButton.backgroundColor = [UIColor clearColor];
        dayButton.frame = buttonFrame;
        dayButton.tag = day;
        [dayButton addTarget:self action:@selector(checkIfMissed:) forControlEvents:UIControlEventTouchUpInside];

        CGFloat labelXOffset = (dayWidth - 20)/2 + 3.5;
        CGRect labelFrame = CGRectMake(labelXOffset, 0, xOffset, yOffset);
        UILabel *dayLabel = [[UILabel alloc] initWithFrame:labelFrame];
        [self decorateLabel:dayLabel day:dayCounter];
        
        [dayButton addSubview:dayLabel];
        [self.dayButtonsMap setObject:dayButton forKey:[NSNumber numberWithUnsignedInteger:day]];
        [weekRowView addSubview:dayButton];
        startWeekDayIndex++;
        dayCounter++;
    }
    [self addSubview:weekRowView];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (nil != self)
    {
        titleHeight = 18;
        weekDayTitleHeight = 18;
        weekDayValueHeight = 18;
        yOffset = 20;
        weeks = 1;
        xOffset = self.bounds.origin.x + 20;
        width = self.bounds.size.width - 40;
        _dayButtonsMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)correctHeightFromDates
{
    CGFloat height = titleHeight + weekDayTitleHeight;
    weeks = self.endComponents.weekOfMonth - self.startComponents.weekOfMonth + 1;
    height += (yOffset * weeks);
    
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
    
    CGRect bounds = self.bounds;
    bounds.size.height = height;
    self.bounds = bounds;
}

- (IBAction)checkIfMissed:(id)sender
{
    NSLog(@"clicked day button");
    
}

- (void)decorateLabel:(UILabel *)label day:(NSUInteger)day
{
    
    label.backgroundColor = [UIColor clearColor];
    label.text = [NSString stringWithFormat:@"%d", day];
    label.textColor = [UIColor darkGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithType:Standard size:standard];
    label.layer.cornerRadius = yOffset/2;
    if (self.todayComponents.day == day)
    {
        label.layer.backgroundColor = [UIColor darkGrayColor].CGColor;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithType:Bold size:standard];
    }
    
}


@end
