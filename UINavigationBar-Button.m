//
//  UINavigationBar-Button.m
//  iStayHealthy
//
//  Created by peterschmidt on 21/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UINavigationBar-Button.h"

@implementation UINavigationBar(Button)
- (UIButton *)buttonWithImageName:(NSString *)name{
    CGRect pozFrame = CGRectMake(CGRectGetMinX(self.bounds) + 60.0, CGRectGetMinY(self.bounds)+2, 190, 40);
    UIButton *pozButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [pozButton setFrame:pozFrame];
    [pozButton setBackgroundColor:[UIColor clearColor]];
    [pozButton setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    [self addSubview:pozButton];
    return pozButton;
}

- (void)addButtonWithImageName:(NSString *)name withTarget:(id)target withSelector:(SEL)selector{
    CGRect pozFrame = CGRectMake(CGRectGetMinX(self.bounds) + 60.0, CGRectGetMinY(self.bounds)+2, 190, 40);
    UIButton *pozButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [pozButton setFrame:pozFrame];
    [pozButton setBackgroundColor:[UIColor clearColor]];
    [pozButton setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    [pozButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:pozButton];    
}

@end
