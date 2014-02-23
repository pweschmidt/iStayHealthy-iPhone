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

- (void)configureCell
{
	UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
	titleView.backgroundColor = [UIColor clearColor];
	self.titleView = titleView;
	[self addSubview:titleView];

	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.frame.size.width, self.frame.size.height - 20)];
	contentView.backgroundColor = [UIColor clearColor];
	[self addSubview:contentView];
	self.labelContentView = contentView;
}

- (void)addDateToTitle:(NSDate *)date
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"dd MMM yy"];
	[self addTitle:[dateFormatter stringFromDate:date] font:[UIFont boldSystemFontOfSize:18]];
}

- (void)addTitle:(NSString *)title font:(UIFont *)font
{
	UILabel *titleLabel = [[UILabel alloc] init];
	titleLabel.frame = CGRectMake(0, 2, self.titleView.frame.size.width, self.titleView.frame.size.height);
	titleLabel.text = title;
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textColor = TEXTCOLOUR;
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.font = font;
	[self.titleView addSubview:titleLabel];
}

- (void)addLabelToContentView:(UILabel *)label
{
    if (nil != label)
    {
        [self.labelContentView addSubview:label];
    }
}

/*
   // Only override drawRect: if you perform custom drawing.
   // An empty implementation adversely affects performance during animation.
   - (void)drawRect:(CGRect)rect
   {
    // Drawing code
   }
 */

@end
