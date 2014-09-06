//
//  PWESBloodPressureCell.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/09/2014.
//
//

#import "PWESBloodPressureCell.h"
#import "Utilities.h"
#import "UIFont+Standard.h"
#import <QuartzCore/QuartzCore.h>

@interface PWESBloodPressureCell ()
{
	CGFloat xMargin, yMargin, labelWidth, textFieldWidth;
	CGRect additionalViewFrame;
}
@property (nonatomic, strong) UIView *mainContentView;
@property (nonatomic, strong) UIColor *shadingColour;
@property (nonatomic, strong) UIColor *normalColour;
@end

@implementation PWESBloodPressureCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self)
	{
		_normalColour = [UIColor whiteColor];
		self.contentView.backgroundColor = [UIColor clearColor];
		xMargin = 20.0f;
		yMargin = 5.0f;
		labelWidth = 100.0f;
		textFieldWidth = 80.0;
		additionalViewFrame = CGRectZero;
		_shadingColour = [UIColor colorWithRed:235.0f / 255.0f
		                                 green:235.0f / 255.0f
		                                  blue:235.0f / 255.0f
		                                 alpha:0.8];
		//		if ([Utilities isIPad])
		//		{
		//			labelWidth = 160.0f;
		//			additionalViewFrame = CGRectMake(xMargin + labelWidth + textFieldWidth + xMargin, yMargin, self.contentView.frame.size.width - 3 * xMargin - labelWidth - textFieldWidth, self.contentView.frame.size.height);
		//		}
	}
	return self;
}

- (UIKeyboardType)adjustedKeyboardType
{
	if (nil == _systoleField)
	{
		return UIKeyboardTypeDefault;
	}
	else
	{
		return _systoleField.keyboardType;
	}
}

- (void)setAdjustedKeyboardType:(UIKeyboardType)adjustedKeyboardType
{
	if (nil != _systoleField)
	{
		_systoleField.keyboardType = adjustedKeyboardType;
	}
}

- (void)createContentWithTitle:(NSString *)title
             textFieldDelegate:(id <UITextFieldDelegate> )textFieldDelegate
                  contentFrame:(CGRect)contentFrame
{
	self.contentView.frame = contentFrame;
	UIView *mainView = [[UIView alloc] initWithFrame:contentFrame];
	mainView.backgroundColor = self.normalColour;
	UILabel *titleLabel = [self leftLabelWithTitle:title];
	UITextField *systoleField = [self textFieldWithTag:kSystoleFieldTag
	                                 textFieldDelegate:textFieldDelegate];
	systoleField.frame = CGRectMake(xMargin + labelWidth, yMargin, textFieldWidth, self.contentView.frame.size.height - 10);
	UIView *additionalView = [self rightContentView];


	UILabel *separator = [[UILabel alloc] init];
	separator.frame = CGRectMake(xMargin + labelWidth + textFieldWidth + 5, yMargin, 20, self.contentView.frame.size.height);
	separator.backgroundColor = [UIColor clearColor];
	separator.text = @"/";
	separator.font = [UIFont fontWithType:Standard size:standard];
	separator.textColor = [UIColor darkGrayColor];

	UITextField *diastoleField = [self textFieldWithTag:kDiastoleFieldTag
	                                  textFieldDelegate:textFieldDelegate];
	diastoleField.frame = CGRectMake(xMargin + labelWidth + textFieldWidth + 30, yMargin, textFieldWidth, self.contentView.frame.size.height - 10);

	[mainView addSubview:titleLabel];
	[mainView addSubview:additionalView];
	[self.contentView addSubview:mainView];
	[self.contentView addSubview:systoleField];
	[self.contentView bringSubviewToFront:systoleField];
	[self.contentView addSubview:separator];
	[self.contentView addSubview:diastoleField];
	[self.contentView bringSubviewToFront:diastoleField];

	self.mainContentView = mainView;
	self.titleLabel = titleLabel;
	self.systoleField = systoleField;
	self.diastoleField = diastoleField;
	self.additionalView = additionalView;
}

- (void)adjustCellWidth:(CGFloat)newWidth;
{
	CGRect currentFrame = self.contentView.frame;
	CGRect newFrame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y, newWidth, currentFrame.size.height);
	self.contentView.frame = newFrame;
	self.mainContentView.frame = newFrame;
	CGFloat widthDelta = newWidth - currentFrame.size.width;
	CGRect newAdditionalViewFrame = CGRectMake(self.additionalView.frame.origin.x, self.additionalView.frame.origin.y, self.additionalView.frame.size.width + widthDelta, self.additionalView.frame.size.height);
	self.additionalView.frame = newAdditionalViewFrame;
}


- (void)clear
{
	[self.contentView.subviews enumerateObjectsUsingBlock: ^(UIView *obj, NSUInteger idx, BOOL *stop) {
	    [obj removeFromSuperview];
	}];
}

- (void)partialShade
{
	self.mainContentView.backgroundColor = self.shadingColour;
	self.systoleField.backgroundColor = self.normalColour;
	self.diastoleField.backgroundColor = self.normalColour;
}

- (void)shade
{
	self.mainContentView.backgroundColor = self.shadingColour;
	self.systoleField.backgroundColor = self.shadingColour;
	self.diastoleField.backgroundColor = self.shadingColour;
	//	self.inputField.alpha = 1.0;
}

- (void)unshade
{
	self.mainContentView.backgroundColor = self.normalColour;
	self.mainContentView.alpha = 1.0;
	self.systoleField.backgroundColor = self.normalColour;
	self.systoleField.alpha = 1.0;
	self.diastoleField.backgroundColor = self.normalColour;
	self.diastoleField.alpha = 1.0;
}

#pragma mark private methods
- (UITextField *)textFieldWithTag:(NSInteger)tag
                textFieldDelegate:(id <UITextFieldDelegate> )textFieldDelegate
{
	UITextField *textField = [[UITextField alloc] init];

	textField.backgroundColor = [UIColor whiteColor];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.tag = tag;
	textField.delegate = textFieldDelegate;
	textField.clearsOnBeginEditing = NO;
	textField.font = [UIFont systemFontOfSize:15];
	textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	textField.returnKeyType = UIReturnKeyDone;
	textField.placeholder = NSLocalizedString(@"Enter Value", nil);
	return textField;
}

- (UILabel *)leftLabelWithTitle:(NSString *)title
{
	UILabel *label = [[UILabel alloc] init];

	label.backgroundColor = [UIColor clearColor];
	label.frame = CGRectMake(xMargin, yMargin, labelWidth, self.contentView.frame.size.height);
	label.text = title;
	label.textColor = TEXTCOLOUR;
	label.font = [UIFont fontWithType:Standard size:standard];
	label.textAlignment = NSTextAlignmentLeft;
	label.numberOfLines = 0;
	label.lineBreakMode = NSLineBreakByWordWrapping;
	return label;
}

- (UIView *)rightContentView
{
	UIView *view = [[UIView alloc] initWithFrame:additionalViewFrame];

	view.backgroundColor = [UIColor clearColor];
	return view;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
}

@end
