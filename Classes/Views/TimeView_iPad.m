//
//  TimeView.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/10/2013.
//
//

#import "TimeView_iPad.h"
#import <QuartzCore/QuartzCore.h>
#import "UIFont+Standard.h"
#import "TimeCounter.h"

@interface TimeView_iPad ()
{
	CGRect timeFrame;
}
@property (nonatomic, strong) NSDate *now;
@property (nonatomic, strong) TimeCounter *timer;
@end

@implementation TimeView_iPad

+ (TimeView_iPad *)viewWithNotification:(UILocalNotification *)notification
                                  frame:(CGRect)frame
{
	TimeView_iPad *view = [[TimeView_iPad alloc] initWithFrame:frame];
	view.now = [NSDate date];
	[view configureViewWithNotification:notification];
	return view;
}

- (void)configureViewWithNotification:(UILocalNotification *)notification
{
	UIImageView *imageView = [self mainImageView];
	[self addSubview:imageView];

	if (nil != notification.alertBody)
	{
		UILabel *label = [self mainTextLabelWithString:notification.alertBody];
		[self addSubview:label];
	}

	TimeCounter *counter = [self counterForNotification:notification];
	self.timer = counter;
	[self addSubview:counter];
}

- (UIImageView *)mainImageView
{
	UIImage *image = [UIImage imageNamed:@"alarm.png"];

	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	imageView.frame = CGRectMake(20, 5, 55, 55);
	imageView.backgroundColor = [UIColor clearColor];
	return imageView;
}

- (UILabel *)mainTextLabelWithString:(NSString *)string
{
	UILabel *label = [[UILabel alloc] init];
	label.font = [UIFont fontWithType:Bold size:large];
	label.frame = CGRectMake(20, 63, self.frame.size.width - 40, 18);
	label.text = string;
	label.textColor = TEXTCOLOUR;
	label.textAlignment = NSTextAlignmentLeft;
	return label;
}

- (TimeCounter *)counterForNotification:(UILocalNotification *)notification
{
	TimeCounter *timer = [TimeCounter viewWithTime:self.now
	                                  notification:notification
	                                         frame:CGRectMake(20, 85, self.frame.size.width - 40, 40)];
	return timer;
}

- (void)startTimer
{
	if (nil != self.timer)
	{
		[self.timer startTimer];
	}
}

- (void)stopTimer
{
	if (nil != self.timer)
	{
		[self.timer stopTimer];
	}
}

@end
