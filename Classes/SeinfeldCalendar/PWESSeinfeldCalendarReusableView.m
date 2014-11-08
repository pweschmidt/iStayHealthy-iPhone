//
//  PWESSeinfeldCalendarReusableView.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/06/2014.
//
//

#import "PWESSeinfeldCalendarReusableView.h"
#import "UIFont+Standard.h"
#import "PWESStar.h"

#define kViewTag 100

@implementation PWESSeinfeldCalendarReusableView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
	}
	return self;
}

- (void)showCalendarInHeader:(SeinfeldCalendar *)calendar
{
	UIView *currentView = [self viewWithTag:kViewTag];
	if (nil != currentView)
	{
		[currentView removeFromSuperview];
	}
	if (nil == calendar)
	{
		UILabel *label = [self emptyLabelWithString:NSLocalizedString(@"My Current Medication Diary", nil)];
		[self addSubview:label];
	}
	else
	{
		UIView *scoreView = [self viewWithScoreFromCalendar:calendar];
		[self addSubview:scoreView];
	}
}

- (void)showEmptyLabel
{
	UILabel *label = [self emptyLabelWithString:NSLocalizedString(@"No Diary Available", nil)];
	[self addSubview:label];
}

- (UILabel *)emptyLabelWithString:(NSString *)string
{
	UILabel *label = [[UILabel alloc] initWithFrame:self.frame];
	label.text = string;
	label.tag = kViewTag;
	label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:20];
	label.textAlignment = NSTextAlignmentCenter;
	label.textColor = DARK_RED;
	return label;
}

- (UIView *)viewWithScoreFromCalendar:(SeinfeldCalendar *)calendar
{
	float score = [calendar.score floatValue];
    if (100 < score)
    {
        score = 100.f;
    }
    else if (0 > 100)
    {
        score = 0.f;
    }
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 0, self.frame.size.width - 40, self.frame.size.height)];
	view.tag = kViewTag;
	view.layer.cornerRadius = 10;
	view.layer.borderColor = [UIColor darkGrayColor].CGColor;
	view.layer.borderWidth = 1;
	view.layer.backgroundColor = [UIColor whiteColor].CGColor;

	UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.frame.size.width - 40, self.frame.size.height / 2)];
	title.textColor = TEXTCOLOUR;
	title.textAlignment = NSTextAlignmentLeft;
	title.font = [UIFont fontWithType:Bold size:large];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateStyle = kDateFormatting;
	NSString *endString = [formatter stringFromDate:calendar.endDate];

	NSString *text = NSLocalizedString(@"Last diary ending", nil);
	title.text = [NSString stringWithFormat:@"%@: %@", text, endString];

	[view addSubview:title];

	UILabel *results = [[UILabel alloc] initWithFrame:CGRectMake(20, self.frame.size.height / 2, 120, self.frame.size.height / 2)];
	results.textColor = TEXTCOLOUR;
	results.textAlignment = NSTextAlignmentLeft;
	results.font = [UIFont fontWithType:Standard size:standard];
	NSString *scoreText = NSLocalizedString(@"Your score:", nil);
	NSString *resultsText = [NSString stringWithFormat:@"%@ %3.2f (%%)", scoreText, score];
	results.text = resultsText;

	[view addSubview:results];

	UIView *starView = [[UIView alloc] initWithFrame:CGRectMake(150, self.frame.size.height / 2, self.frame.size.width - 150, self.frame.size.height / 2)];

	CGFloat xOffset = starView.frame.origin.x;
	CGFloat yOffset = ((self.frame.size.height / 2) - 17) / 2;
	CGFloat width = 17;
	CGFloat height = 17;
	float goldenRule = floorf(score / 20);
	for (int i = 0; i < 5; ++i)
	{
		CGFloat x = xOffset + i * width + 10;
		CGRect frame = CGRectMake(x, yOffset, width, height);
		PWESStar *star = nil;
		if (i < goldenRule)
		{
			star = [PWESStar starWithColourAndFrame:frame];
		}
		else
		{
			star = [PWESStar starWithoutColourAndFrame:frame];
		}
		[starView addSubview:star];
	}
	[view addSubview:starView];
	return view;
}

@end
