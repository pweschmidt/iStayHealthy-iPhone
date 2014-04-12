//
//  BaseCollectionViewCell.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/11/2013.
//
//

#import "BaseCollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "GeneralSettings.h"
#import "Contacts.h"
#import "UIFont+Standard.h"

@interface BaseCollectionViewCell ()
@property (nonatomic, strong, readwrite) UIView *titleView;
@property (nonatomic, strong, readwrite) UIView *labelContentView;
@end

@implementation BaseCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		self.layer.cornerRadius = 6;
		self.layer.borderColor = [UIColor lightGrayColor].CGColor;
		self.layer.backgroundColor = [UIColor whiteColor].CGColor;
		self.layer.borderWidth = 2;
	}
	return self;
}

- (void)setManagedObject:(NSManagedObject *)managedObject
{
	if (nil != _managedObject)
	{
		_managedObject = nil;
	}
	_managedObject = managedObject;
	[self configureCell];
}

- (void)clear
{
	[self.contentView.subviews enumerateObjectsUsingBlock: ^(UIView *view, NSUInteger idx, BOOL *stop) {
	    [view removeFromSuperview];
	}];
}

- (void)configureCell
{
	[self clear];
	UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
	titleView.backgroundColor = [UIColor clearColor];
	self.titleView = titleView;
	[self.contentView addSubview:titleView];

	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.frame.size.width, self.frame.size.height - 20)];
	contentView.backgroundColor = [UIColor clearColor];
	[self.contentView addSubview:contentView];
	self.labelContentView = contentView;
}

- (void)addDateToTitle:(NSDate *)date
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"dd MMM yyyy"];
	UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, self.titleView.frame.size.width, self.titleView.frame.size.height)];
	dateLabel.layer.cornerRadius = 6;
	dateLabel.layer.borderWidth = 1;
	dateLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
	dateLabel.backgroundColor = [UIColor lightGrayColor];
	dateLabel.textColor = [UIColor whiteColor];
	dateLabel.font = [UIFont fontWithType:Bold size:standard];
	dateLabel.text = [dateFormatter stringFromDate:date];
	dateLabel.textAlignment = NSTextAlignmentCenter;
	[self.titleView addSubview:dateLabel];
}

- (void)addTitle:(NSString *)title
{
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, self.titleView.frame.size.width, self.titleView.frame.size.height)];
	titleLabel.layer.cornerRadius = 6;
	titleLabel.layer.borderWidth = 1;
	titleLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
	titleLabel.backgroundColor = [UIColor lightGrayColor];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.font = [UIFont fontWithType:Bold size:standard];
	titleLabel.text = title;
	titleLabel.textAlignment = NSTextAlignmentCenter;
	[self.titleView addSubview:titleLabel];
}

- (void)addLabelToContentView:(UILabel *)label
{
	if (nil != label)
	{
		[self.labelContentView addSubview:label];
	}
}

@end
