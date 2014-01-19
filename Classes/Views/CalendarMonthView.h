//
//  CalendarMonthView.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/01/2014.
//
//

#import <UIKit/UIKit.h>

@class SeinfeldCalendar;

@interface CalendarMonthView : UIView

+ (CalendarMonthView *)calendarMonthViewForCalendar:(SeinfeldCalendar *)calendar
                                    startComponents:(NSDateComponents *)startComponents
                                      endComponents:(NSDateComponents *)endComponents
                                     suggestedFrame:(CGRect)suggestedFrame;
@end
