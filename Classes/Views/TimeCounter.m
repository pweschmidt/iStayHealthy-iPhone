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
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) UILocalNotification *notification;
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
	counter.date = date;
	counter.notification = notification;
	return counter;
}

- (void)dealloc
{
	[self stopTimer];
}

- (void)configureWithDate:(NSDate *)date notification:(UILocalNotification *)notification
{
	NSArray *subviews = [self subviews];
	if (nil != subviews && 0 < subviews.count)
	{
		[subviews enumerateObjectsUsingBlock: ^(UIView *obj, NSUInteger idx, BOOL *stop) {
		    [obj removeFromSuperview];
		}];
	}
	CGFloat width = self.frame.size.width / 3;
	UILabel *intervalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, self.frame.size.height)];
	intervalLabel.backgroundColor = [UIColor clearColor];
	intervalLabel.font = [UIFont fontWithType:Standard size:standard];
	intervalLabel.textColor = TEXTCOLOUR;
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
	label.textColor = TEXTCOLOUR;
	label.textAlignment = NSTextAlignmentLeft;

	NSDate *now = [NSDate date];
	NSDateComponents *components = [[PWESCalendar sharedInstance] dateComponentsForDate:now];
	NSDateComponents *fireComponents = [[PWESCalendar sharedInstance] dateComponentsForDate:fireDate];

	[self computeDeltaFromCurrentComponent:components fireComponent:fireComponents];
	if (0 == hour)
	{
		label.textColor = DARK_RED;
	}
	self.timerLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hour, (long)minute, (long)second];

	label.text = self.timeString;

	NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateLabelWithTimer:) userInfo:nil repeats:YES];
	[timer fire];
	self.counter = timer;
	self.timerLabel = label;
	return label;
}

- (void)computeDeltaFromCurrentComponent:(NSDateComponents *)current fireComponent:(NSDateComponents *)fire
{
	NSTimeInterval currentTime  = 3600 * current.hour + 60 * current.minute + current.second;
	NSTimeInterval fireTime     = 3600 * fire.hour + 60 * fire.minute + fire.second;
	NSTimeInterval day          = 3600 * 24;
	NSTimeInterval delta = fireTime - currentTime;
	if (0 > delta)
	{
		delta += day;
	}
	NSTimeInterval hourDelta = floor(delta / 3600);

	NSTimeInterval minuteDelta = delta - (hourDelta * 3600);
	minuteDelta = floor(minuteDelta / 60);
	NSTimeInterval secondDelta = delta - (hourDelta * 3600) - (minuteDelta * 60);

	hour = (NSInteger)hourDelta;
	minute = (NSInteger)minuteDelta;
	second = (NSInteger)secondDelta;
}

- (void)updateLabelWithTimer:(NSTimer *)timer
{
	second--;
	if (0 > second)
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
	if (0 == hour)
	{
		self.timerLabel.textColor = DARK_RED;
	}
    else
    {
        self.timerLabel.textColor = TEXTCOLOUR;
    }
	self.timerLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hour, (long)minute, (long)second];
}

- (void)stopTimer
{
	if (nil != self.counter)
	{
		[self.counter invalidate];
		self.counter = nil;
	}
}

- (void)startTimer
{
	[self configureWithDate:self.date notification:self.notification];
}

@end
