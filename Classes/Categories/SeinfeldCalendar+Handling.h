//
//  SeinfeldCalendar+Handling.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 25/01/2014.
//
//

#import "SeinfeldCalendar.h"
#import "NSManagedObject+Handling.h"
#import "SeinfeldCalendarEntry.h"

@interface SeinfeldCalendar (Handling)
- (SeinfeldCalendarEntry *)entryForDay:(NSUInteger)day
                                 month:(NSUInteger)month
                                  year:(NSUInteger)year;
@end
