//
//  TimeView_iPad.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/06/2014.
//
//

#import <UIKit/UIKit.h>

@interface TimeView_iPad : UIView
+ (TimeView_iPad *)viewWithNotification:(UILocalNotification *)notification
                                  frame:(CGRect)frame;

- (void)stopTimer;
- (void)startTimer;

@end
