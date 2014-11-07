//
//  PWESDataManager.m
//  HealthCharts
//
//  Created by Peter Schmidt on 27/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import "PWESDataManager.h"
#import "Results.h"
#import "Constants.h"


@implementation PWESDataManager
+ (id)sharedInstance
{
    static PWESDataManager *manager = nil;
    static dispatch_once_t token;

    dispatch_once(&token, ^{
                      manager = [[PWESDataManager alloc] init];
                  });
    return manager;
}

- (PWESDataTuple *)filterOrderedRawResults:(NSArray *)rawResults
                                      type:(NSString *)type
                                     error:(NSError **)error
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[self filterStringForType:type]];
    NSArray *filteredArray = [rawResults filteredArrayUsingPredicate:predicate];

    NSArray *values = [filteredArray valueForKey:type];
    NSArray *dates = [filteredArray valueForKey:kResultsDate];

    if (nil == values || dates == nil)
    {
        if (NULL != error)
        {
            *error = [NSError errorWithDomain:@"com.pweschmidt.healthchars" code:100 userInfo:nil];
        }
        return nil;
    }
    if (values.count != dates.count)
    {
        if (NULL != error)
        {
            *error = [NSError errorWithDomain:@"com.pweschmidt.healthchars" code:100 userInfo:nil];
        }
        return nil;
    }
    PWESDataTuple *tuple = [PWESDataTuple resultsTupleWithResultsArray:values dates:dates type:type];
    return tuple;
}

- (NSArray *)combinedTimelineForOrderedRawResults:(NSArray *)rawResults
                                            types:(PWESResultsTypes *)types
                                            error:(NSError **)error
{
    if (nil == rawResults || nil == types)
    {
        if (NULL != error)
        {
            *error = [NSError errorWithDomain:@"com.pweschmidt.healthchars" code:100 userInfo:nil];
        }
        return nil;
    }
    if (!types.isDualType)
    {
        // a combination must have at least 2 types
        if (NULL != error)
        {
            *error = [NSError errorWithDomain:@"com.pweschmidt.healthchars" code:100 userInfo:nil];
        }
        return nil;
    }
    NSPredicate *predicate = [self filterPredicateFromTypes:types];
    if (predicate)
    {
        NSArray *filteredArray = [rawResults filteredArrayUsingPredicate:predicate];
        return [filteredArray valueForKey:kResultsDate];
    }
    if (NULL != error)
    {
        *error = [NSError errorWithDomain:@"com.pweschmidt.healthchars" code:100 userInfo:nil];
    }
    return nil;
}

- (NSPredicate *)filterPredicateFromTypes:(PWESResultsTypes *)types
{
    NSString *singleFilter = [self filterStringForType:types.mainType];

    if (types.isDualType)
    {
        NSString *secondFilter = [self filterStringForType:types.secondaryType];
        NSString *combinedFilter = [NSString stringWithFormat:@"%@ OR %@", singleFilter, secondFilter];
        return [NSPredicate predicateWithFormat:combinedFilter];
    }
    else
    {
        return [NSPredicate predicateWithFormat:singleFilter];
    }
}

- (NSString *)filterStringForType:(NSString *)type
{
    if ([type isEqualToString:kViralLoad] || [type isEqualToString:kHepCViralLoad])
    {
        return [NSString stringWithFormat:@"%@ >= 0", type];
    }
    else
    {
        return [NSString stringWithFormat:@"%@ > 0", type];
    }
}

- (NSPredicate *)filterForTypesArray:(NSArray *)resultsTypes
{
    if (nil == resultsTypes || 0 == resultsTypes.count)
    {
        return nil;
    }
    __block NSMutableArray *predicates = [NSMutableArray array];
    [resultsTypes enumerateObjectsUsingBlock:^(NSString *type, NSUInteger idx, BOOL *stop) {
         NSString *predicateString = [self filterStringForType:type];
         NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
         [predicates addObject:predicate];
     }];

    NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
    return compoundPredicate;
}

@end
