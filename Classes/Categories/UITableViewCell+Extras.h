//
//  UITableViewCell+Extras.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 08/09/2013.
//
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (Extras)
- (void)configureCellWithDate:(NSDate *)date;
- (void)updateDate:(NSDate *)date;
@end
