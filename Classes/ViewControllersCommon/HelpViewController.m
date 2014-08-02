//
//  HelpViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 17/07/2014.
//
//

#import "HelpViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "HelpSubjects.h"
#import "UILabel+Standard.h"
#import "Utilities.h"

static NSDictionary *helpSubjects()
{
	return @{ kHelpDataLoss : kHelpDataLossExplanation };
}

@interface HelpViewController ()
@property (nonatomic, assign) BOOL isPopover;

@end

@implementation HelpViewController
- (id)initAsPopoverController
{
	self = [super init];
	if (nil != self)
	{
		_isPopover = YES;
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.navigationItem.title = NSLocalizedString(@"Help", nil);
	self.view.backgroundColor = DEFAULT_BACKGROUND;
	__block CGFloat offset = 75;
	NSDictionary *subjects = helpSubjects();
	[subjects enumerateKeysAndObjectsUsingBlock: ^(NSString *key, NSString *obj, BOOL *stop) {
	    UIView *header = [self headlineViewWithOffset:offset subject:key];
	    offset += 30;
	    UIView *text = [self contentViewWithOffset:offset explanation:obj];
	    offset += 20;
	    [self.view addSubview:header];
	    [self.view addSubview:text];
	}];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (UIView *)headlineViewWithOffset:(CGFloat)offset subject:(NSString *)subject
{
	UIView *view = [[UIView alloc] init];


	view.frame = CGRectMake(20, offset, self.view.bounds.size.width - 40, 20);
	view.backgroundColor = [UIColor clearColor];

	UILabel *label = [UILabel standardLabel];
	label.frame = CGRectMake(0, 0, view.frame.size.width, 20);
	label.text = subject;
	label.textAlignment = NSTextAlignmentLeft;

	[view addSubview:label];

	return view;
}

- (UIView *)contentViewWithOffset:(CGFloat)offset explanation:(NSString *)explanation
{
	UIView *view = [[UIView alloc] init];

	CGFloat width = self.view.bounds.size.width - 40;
	if ([Utilities isIPad])
	{
		width = 270;
	}
	view.frame = CGRectMake(20, offset, width, 320);
	view.backgroundColor = [UIColor clearColor];
	view.layer.backgroundColor = [UIColor whiteColor].CGColor;
	view.layer.cornerRadius = 10.0f;
	view.layer.borderColor = [UIColor darkGrayColor].CGColor;
	view.layer.borderWidth = 1.0f;

	UILabel *label = [UILabel standardLabel];
	label.frame = CGRectMake(10, 5, width - 20, 300);
	label.text = explanation;
	label.textAlignment = NSTextAlignmentLeft;
	label.numberOfLines = 0;
	label.textColor = [UIColor blackColor];
	[view addSubview:label];

	return view;
}

@end
