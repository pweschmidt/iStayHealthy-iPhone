//
//  TimeCounter.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/05/2014.
//
//

#import <UIKit/UIKit.h>

@interface TimeCounter : UIView
+ (TimeCounter *)viewWithTime:(NSDate *)date
                 notification:(UILocalNotification *)notification
                        frame:(CGRect)frame;
- (void)stopTimer;

@end
