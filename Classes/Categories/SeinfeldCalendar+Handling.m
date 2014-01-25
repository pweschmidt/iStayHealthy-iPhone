//
//  SeinfeldCalendar+Handling.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 25/01/2014.
//
//

#import "SeinfeldCalendar+Handling.h"
#import "Utilities.h"

@implementation SeinfeldCalendar (Handling)
- (SeinfeldCalendarEntry *)entryForDay:(NSUInteger)day
                                 month:(NSUInteger)month
                                  year:(NSUInteger)year
{
    if (nil == self.entries || 0 == self.entries.count)
    {
        return nil;
    }
    SeinfeldCalendarEntry *foundEntry = nil;
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = day;
    components.month = month;
    components.year = year;
    
    for (SeinfeldCalendarEntry *entry in self.entries)
    {
        NSDateComponents *entryComponent = [Utilities dateComponentsForDate:entry.date];
        if (entryComponent.day == components.day &&
            entryComponent.month == components.month &&
            entryComponent.year == components.year)
        {
            foundEntry = entry;
            break;
        }
    }
    
    return foundEntry;
}
@end
