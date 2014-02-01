//
//  SeinfeldCalendar.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 01/02/2014.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SeinfeldCalendarEntry;

@interface SeinfeldCalendar : NSManagedObject

@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSNumber * isCompleted;
@property (nonatomic, retain) NSString * uID;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSSet *entries;
@end

@interface SeinfeldCalendar (CoreDataGeneratedAccessors)

- (void)addEntriesObject:(SeinfeldCalendarEntry *)value;
- (void)removeEntriesObject:(SeinfeldCalendarEntry *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;

@end
