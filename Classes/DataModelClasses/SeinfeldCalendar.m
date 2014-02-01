//
//  SeinfeldCalendar.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 01/02/2014.
//
//

#import "SeinfeldCalendar.h"
#import "SeinfeldCalendarEntry.h"


@implementation SeinfeldCalendar

@dynamic endDate;
@dynamic startDate;
@dynamic isCompleted;
@dynamic uID;
@dynamic score;
@dynamic entries;
- (void)addEntriesObject:(NSManagedObject *)value
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"entries" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"entries"] addObject:value];
    [self didChangeValueForKey:@"entries" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
}

- (void)removeEntriesObject:(NSManagedObject *)value
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"entries" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"entries"] removeObject:value];
    [self didChangeValueForKey:@"entries" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
}

- (void)addEntries:(NSSet *)values
{
    [self willChangeValueForKey:@"entries" withSetMutation:NSKeyValueUnionSetMutation usingObjects:values];
    [[self primitiveValueForKey:@"entries"] unionSet:values];
    [self didChangeValueForKey:@"entries" withSetMutation:NSKeyValueUnionSetMutation usingObjects:values];
    
}

- (void)removeEntries:(NSSet *)values
{
    [self willChangeValueForKey:@"entries" withSetMutation:NSKeyValueMinusSetMutation usingObjects:values];
    [[self primitiveValueForKey:@"entries"] minusSet:values];
    [self didChangeValueForKey:@"entries" withSetMutation:NSKeyValueMinusSetMutation usingObjects:values];
}
@end
