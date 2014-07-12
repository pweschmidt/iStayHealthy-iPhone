//
//  UIBarButtonItem+iStayHealthy.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 08/02/2014.
//
//

#import "UIBarButtonItem+iStayHealthy.h"
#import "Menus.h"
#import <objc/runtime.h>

#define kButtonTag 99

@implementation UIBarButtonItem (iStayHealthy)
+ (UIBarButtonItem *)barButtonItemForTitle:(NSString *)title
                                    target:(id)target
                                    action:(SEL)action
                                 buttonTag:(NSInteger)buttonTag
{
	UIImageView *buttonView = [Menus buttonImageviewForTitle:title];
	if (nil == buttonView)
	{
		return nil;
	}
	UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
	customButton.frame = CGRectMake(0, 0, 22, 22);
	customButton.backgroundColor = [UIColor clearColor];
	customButton.tag = buttonTag;
	[customButton addSubview:buttonView];
	[customButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	return [[[self class] alloc] initWithCustomView:customButton];
}

@end
