//
//  TimeView.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/10/2013.
//
//

#import "TimeView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIFont+Standard.h"

@interface TimeView ()
{
	CGRect timeFrame;
}
@end

@implementation TimeView

+ (TimeView *)viewWithTime:(NSDate *)date
                     frame:(CGRect)frame
{
	TimeView *view = [[TimeView alloc] initWithFrame:frame];
	UILabel *label = [view timeLabelWithDate:date];
	[view addSubview:label];
	return view;
}

- (UILabel *)timeLabelWithDate:(NSDate *)date
{
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	label.layer.cornerRadius = 6;
	label.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.locale = [NSLocale currentLocale];
	formatter.timeStyle = NSDateFormatterShortStyle;

	NSString *timeString = [formatter stringFromDate:date];
	if (nil != timeString)
	{
		label.text = timeString;
	}
	label.textColor = [UIColor whiteColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.numberOfLines = 0;
	label.font = [UIFont fontWithType:Bold size:large];
	return label;
}

@end
