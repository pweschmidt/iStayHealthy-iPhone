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
@property (nonatomic, strong) NSMutableDictionary *dayButtonsMap;
@end

@implementation CalendarMonthView


+ (CalendarMonthView *)calendarMonthViewForCalendar:(SeinfeldCalendar *)calendar
                                    startComponents:(NSDateComponents *)startComponents
                                      endComponents:(NSDateComponents *)endComponents
                                     suggestedFrame:(CGRect)suggestedFrame
{
    CalendarMonthView *monthView = [[CalendarMonthView alloc] initWithFrame:suggestedFrame];
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
        CGFloat yDay = heightOffset + yOffset * weekIndex;
        CGRect buttonFrame = CGRectMake(xDay, yDay, dayWidth, yOffset);
        UIButton *dayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        dayButton.backgroundColor = [UIColor clearColor];
        dayButton.frame = buttonFrame;
        dayButton.tag = day;
        [dayButton addTarget:self action:@selector(checkIfMissed:) forControlEvents:UIControlEventTouchUpInside];

        CGFloat labelXOffset = (dayWidth - 20)/2 + 3.5;
        CGRect labelFrame = CGRectMake(labelXOffset, 0, xOffset, yOffset);
        UILabel *dayLabel = [[UILabel alloc] initWithFrame:labelFrame];
        dayLabel.backgroundColor = [UIColor clearColor];
        dayLabel.text = [NSString stringWithFormat:@"%d", dayCounter];
        dayLabel.textColor = [UIColor darkGrayColor];
        dayLabel.textAlignment = NSTextAlignmentCenter;
        dayLabel.font = [UIFont systemFontOfSize:15];
        dayLabel.layer.cornerRadius = yOffset/2;
        
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


@end
