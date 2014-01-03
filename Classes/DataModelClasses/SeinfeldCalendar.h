//
//  SeinfeldCalendar.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 03/01/2014.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SeinfeldCalendar : NSManagedObject

@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * isCompleted;
@property (nonatomic, retain) NSString * uID;
@property (nonatomic, retain) NSSet *entries;
@end

@interface SeinfeldCalendar (CoreDataGeneratedAccessors)

- (void)addEntriesObject:(NSManagedObject *)value;
- (void)removeEntriesObject:(NSManagedObject *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;

@end
