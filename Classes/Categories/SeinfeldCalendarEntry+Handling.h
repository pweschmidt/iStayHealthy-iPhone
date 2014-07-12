//
//  SeinfeldCalendarEntry+Handling.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 12/07/2014.
//
//

#import "SeinfeldCalendarEntry.h"
#import "NSManagedObject+Handling.h"

@interface SeinfeldCalendarEntry (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes;
- (NSDictionary *)dictionaryForAttributes;
- (BOOL)isEqualToDictionary:(NSDictionary *)attributes;
@end
