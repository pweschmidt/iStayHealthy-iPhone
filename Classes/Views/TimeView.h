//
//  TimeView.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/10/2013.
//
//

#import <UIKit/UIKit.h>

@interface TimeView : UIView
+ (TimeView *)viewWithTime:(NSDate *)date
                     frame:(CGRect)frame;
@end
