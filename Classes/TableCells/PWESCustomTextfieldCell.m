//
//  PWESCustomTextfieldCell.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/04/2014.
//
//

#import "PWESCustomTextfieldCell.h"
#import "Utilities.h"
#import "UIFont+Standard.h"
#import "GeneralSettings.h"

@interface PWESCustomTextfieldCell ()
{
	CGFloat xMargin, yMargin, labelWidth, textFieldWidth;
	CGRect additionalViewFrame;
}
@property (nonatomic, strong) UIView *mainContentView;
@property (nonatomic, strong) UIColor *shadingColour;
@property (nonatomic, strong) UIColor *normalColour;
@end

@implementation PWESCustomTextfieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self)
	{
		_normalColour = [UIColor whiteColor];
		self.contentView.backgroundColor = [UIColor clearColor];
		xMargin = 20.0f;
		yMargin = 0.0f;
		labelWidth = 100.0f;
		textFieldWidth = 180.0;
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

- (void)createContentWithTitle:(NSString *)title
                  textFieldTag:(NSInteger)textFieldTag
             textFieldDelegate:(id <UITextFieldDelegate> )textFieldDelegate
             hasNumericalInput:(BOOL)hasNumericalInput
                  contentFrame:(CGRect)contentFrame
{
	self.contentView.frame = contentFrame;
	UIView *mainView = [[UIView alloc] initWithFrame:contentFrame];
	mainView.backgroundColor = self.normalColour;
	UILabel *titleLabel = [self leftLabelWithTitle:title];
	UITextField *textField = [self textFieldWithTag:textFieldTag
	                              textFieldDelegate:textFieldDelegate
	                              hasNumericalInput:hasNumericalInput];
	UIView *additionalView = [self rightContentView];

	[mainView addSubview:titleLabel];
	[mainView addSubview:additionalView];
	[self.contentView addSubview:mainView];
	[self.contentView addSubview:textField];
	[self.contentView bringSubviewToFront:textField];

	self.mainContentView = mainView;
	self.titleLabel = titleLabel;
	self.inputField = textField;
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
	self.inputField.backgroundColor = self.normalColour;
}

- (void)shade
{
	self.mainContentView.backgroundColor = self.shadingColour;
	self.inputField.backgroundColor = self.shadingColour;
//	self.inputField.alpha = 1.0;
}

- (void)unshade
{
	self.mainContentView.backgroundColor = self.normalColour;
	self.mainContentView.alpha = 1.0;
	self.inputField.backgroundColor = self.normalColour;
	self.inputField.alpha = 1.0;
}

#pragma mark private methods
- (UITextField *)textFieldWithTag:(NSInteger)tag
                textFieldDelegate:(id <UITextFieldDelegate> )textFieldDelegate
                hasNumericalInput:(BOOL)hasNumericalInput
{
	UITextField *textField = [[UITextField alloc] init];
	textField.backgroundColor = [UIColor whiteColor];
	textField.tag = tag;
	textField.delegate = textFieldDelegate;
	textField.frame = CGRectMake(xMargin + labelWidth, yMargin, textFieldWidth, self.contentView.frame.size.height);
	textField.clearsOnBeginEditing = YES;
	textField.font = [UIFont systemFontOfSize:15];
	if (hasNumericalInput)
	{
		textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	}
	else
	{
		textField.keyboardType = UIKeyboardTypeDefault;
	}

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
