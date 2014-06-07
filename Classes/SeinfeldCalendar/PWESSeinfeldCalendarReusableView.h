//
//  PWESSeinfeldCalendarReusableView.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/06/2014.
//
//

#import <UIKit/UIKit.h>
#import "SeinfeldCalendar.h"
#import "SeinfeldCalendarEntry.h"

@interface PWESSeinfeldCalendarReusableView : UICollectionReusableView
- (void)showCalendarInHeader:(SeinfeldCalendar *)calendar;
- (void)showEmptyLabel;
@end
