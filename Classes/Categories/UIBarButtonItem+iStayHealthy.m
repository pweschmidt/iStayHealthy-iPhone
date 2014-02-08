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

+ (UIBarButtonItem *)barButtonItemForTitle:(NSString *)title target:(id)target action:(SEL)action
{
    UIImageView *buttonView = [Menus buttonImageviewForTitle:title];
    if (nil == buttonView)
    {
        return nil;
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 20, 20);
    button.backgroundColor = [UIColor clearColor];
    button.tag = kButtonTag;
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button addSubview:buttonView];
    return [[[self class] alloc] initWithCustomView:button];
}

@end
