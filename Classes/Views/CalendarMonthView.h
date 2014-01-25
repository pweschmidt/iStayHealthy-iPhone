//
//  CalendarMonthView.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/01/2014.
//
//

#import <UIKit/UIKit.h>
#import "SeinfeldCalendarDelegate.h"
@class SeinfeldCalendar;

@interface CalendarMonthView : UIView <UIAlertViewDelegate>
@property (nonatomic, weak) id<SeinfeldCalendarDelegate>calendarDelegate;
+ (CalendarMonthView *)calendarMonthViewForCalendar:(SeinfeldCalendar *)calendar
                                    startComponents:(NSDateComponents *)startComponents
                                      endComponents:(NSDateComponents *)endComponents
                                courseEndComponents:(NSDateComponents *)courseEndComponents
                                     suggestedFrame:(CGRect)suggestedFrame;
@end
