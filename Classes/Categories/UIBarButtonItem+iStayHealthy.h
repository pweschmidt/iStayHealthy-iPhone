//
//  UIBarButtonItem+iStayHealthy.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 08/02/2014.
//
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (iStayHealthy)
+ (UIBarButtonItem *)barButtonItemForTitle:(NSString *)title target:(id)target action:(SEL)action;
@end
