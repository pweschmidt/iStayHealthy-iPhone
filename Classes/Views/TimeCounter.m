//
//  TimeCounter.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/05/2014.
//
//

#import "TimeCounter.h"
#import "UIFont+Standard.h"
#import "PWESCalendar.h"

@interface TimeCounter ()
{
	NSInteger hour;
	NSInteger minute;
	NSInteger second;
}
@property (nonatomic, strong) NSTimer *counter;
@property (nonatomic, strong) UILabel *timerLabel;
@property (nonatomic, strong) NSString *timeString;
@end

@implementation TimeCounter

+ (TimeCounter *)viewWithTime:(NSDate *)date
                 notification:(UILocalNotification *)notification
                        frame:(CGRect)frame
{
	TimeCounter *counter = [[TimeCounter alloc] initWithFrame:frame];
	[counter configureWithDate:date notification:notification];
	return counter;
}

- (void)dealloc
{
	[self stopTimer];
}

- (void)configureWithDate:(NSDate *)date notification:(UILocalNotification *)notification
{
	CGFloat width = self.frame.size.width / 3;
	UILabel *intervalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, self.frame.size.height)];
	intervalLabel.backgroundColor = [UIColor clearColor];
	intervalLabel.font = [UIFont fontWithType:Standard size:standard];
	intervalLabel.textColor = DARK_RED;
	intervalLabel.textAlignment = NSTextAlignmentLeft;
	NSString *intervalText = NSLocalizedString(@"daily", nil);
	if (nil != notification.userInfo)
	{
		NSString *text = [notification.userInfo objectForKey:kAppNotificationIntervalKey];
		if (nil != text)
		{
			intervalText = NSLocalizedString(text, nil);
		}
	}
	intervalLabel.text = intervalText;

	UILabel *counterLabel = [self counterLabelWithOffset:width fireDate:notification.fireDate];
	[self addSubview:intervalLabel];
	[self addSubview:counterLabel];
}

- (UILabel *)counterLabelWithOffset:(CGFloat)offset fireDate:(NSDate *)fireDate
{
	UILabel *label = [[UILabel alloc] init];
	label.frame = CGRectMake(offset + 5, 0, self.frame.size.width - offset - 5, self.frame.size.height);
	label.font = [UIFont fontWithType:Bold size:standard];
	label.textColor = DARK_RED;
	label.textAlignment = NSTextAlignmentLeft;

	NSDate *now = [NSDate date];
	NSDateComponents *components = [[PWESCalendar sharedInstance] dateComponentsForDate:now];
	NSDateComponents *fireComponents = [[PWESCalendar sharedInstance] dateComponentsForDate:fireDate];

	hour = components.hour - fireComponents.hour;
	minute = components.minute - fireComponents.minute;
	second = components.second - fireComponents.second;

	self.timeString = [NSString stringWithFormat:@"%ld:%ld:%ld", (long)hour, (long)minute, (long)second];

	label.text = self.timeString;

	self.counter = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateLabelWithTimer:) userInfo:nil repeats:YES];
	[self.counter fire];

	self.timerLabel = label;
	return label;
}

- (void)updateLabelWithTimer:(NSTimer *)timer;
{
	NSInteger nextSecond = second - 1;
	if (0 > nextSecond)
	{
		second = 59;
		minute--;
	}
	if (0 > minute)
	{
		minute = 59;
		hour--;
	}
	if (0 > hour)
	{
		hour = 0;
	}
	self.timeString = [NSString stringWithFormat:@"%ld:%ld:%ld", (long)hour, (long)minute, (long)second];
	[self performSelectorOnMainThread:@selector(updateLabelText) withObject:nil waitUntilDone:YES];
}

- (void)updateLabelText
{
	self.timerLabel.text = self.timeString;
	[self.timerLabel setNeedsDisplay];
}

- (void)stopTimer
{
	if (nil != self.counter)
	{
		[self.counter invalidate];
		self.counter = nil;
	}
}

@end
