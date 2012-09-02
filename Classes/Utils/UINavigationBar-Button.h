//
//  UINavigationBar-Button.h
//  iStayHealthy
//
//  Created by peterschmidt on 21/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UINavigationBar(Button)
- (UIButton *)buttonWithImageName:(NSString *)name;
- (void)addButtonWithImageName:(NSString *)name withTarget:(id)target withSelector:(SEL)selector;
- (void)addButtonWithTitle:(NSString *)title target:(id)target selector:(SEL)selector;
@end
