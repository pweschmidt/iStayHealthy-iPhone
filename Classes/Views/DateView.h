//
//  DateView.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 22/09/2013.
//
//

#import <UIKit/UIKit.h>

@interface DateView : UIView
+ (DateView *)viewWithDate:(NSDate *)date
                     frame:(CGRect)frame;
@end
