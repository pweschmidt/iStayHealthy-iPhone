//
//  UINavigationBar-Button.m
//  iStayHealthy
//
//  Created by peterschmidt on 21/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UINavigationBar-Button.h"
#import "UIFont+Standard.h"
#import "Constants.h"
#import "GeneralSettings.h"
@implementation UINavigationBar(Button)
- (UIButton *)buttonWithImageName:(NSString *)name
{
    CGRect pozFrame = CGRectMake(CGRectGetMinX(self.bounds) + 60.0, CGRectGetMinY(self.bounds)+2, 190, 40);
    UIButton *pozButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [pozButton setFrame:pozFrame];
    [pozButton setBackgroundColor:[UIColor clearColor]];
    [pozButton setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    [self addSubview:pozButton];
    return pozButton;
}

- (void)addButtonWithImageName:(NSString *)name withTarget:(id)target withSelector:(SEL)selector
{
    CGRect pozFrame = CGRectMake(CGRectGetMinX(self.bounds) + 60.0, CGRectGetMinY(self.bounds)+2, 190, 40);
    UIButton *pozButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [pozButton setFrame:pozFrame];
    [pozButton setBackgroundColor:[UIColor clearColor]];
    [pozButton setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    [pozButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:pozButton];    
}

- (void)addButtonWithTitle:(NSString *)title target:(id)target selector:(SEL)selector
{
    self.translucent = NO;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGSize size = self.bounds.size;
    float xOffset = size.width/2 - 100;
    CGRect buttonFrame = CGRectMake(xOffset, CGRectGetMinY(self.bounds) + 2, 190, 40);
    button.frame = buttonFrame;
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_29.png"]];
    
    iconView.frame = CGRectMake(1, 7, 29, 29);
    
    UIImageView *pozView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pozicon.png"]];
    float pozXOffset = 190 - 46;
    pozView.frame = CGRectMake(pozXOffset, 7, 45, 29);

    UILabel *label = [[UILabel alloc]init];
    label.frame = CGRectMake(30, 0, 114, 44);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = TEXTCOLOUR;
    label.text = NSLocalizedString(title, title);
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.font = [UIFont fontWithType:Bold size:20];
    
    [button addSubview:label];
    [button addSubview:iconView];
    [button addSubview:pozView];
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
}


@end
