//
//  UILabel+Standard.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/10/2013.
//
//

#import "UILabel+Standard.h"
#import "UIFont+Standard.h"

@implementation UILabel (Standard)
+ (UILabel *)standardLabel
{
	UILabel *label = [[UILabel alloc] init];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont fontWithType:Standard size:standard];
	label.textColor = TEXTCOLOUR;
	label.textAlignment = NSTextAlignmentLeft;
	return label;
}

@end
