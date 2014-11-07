//
//  PWESDataManager.h
//  HealthCharts
//
//  Created by Peter Schmidt on 27/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PWESChartsConstants.h"
#import "PWESDataTuple.h"
#import "PWESResultsTypes.h"

@interface PWESDataManager : NSObject

/**
   returns a singleton for PWESDataManager
 */
+ (id)sharedInstance;

/**
   @param rawResults the results array. It is assumed it is ordered by results date
   @param type the data type we want to filter for
   @param error is nil if results can be obtained
   @return a PWESDataTuple or nil if error
 */
- (PWESDataTuple *)filterOrderedRawResults:(NSArray *)rawResults
                                      type:(NSString *)type
                                     error:(NSError **)error;

/**
   @param rawResults. It is assumed the array is ordered by results date
   @param types
   @param error will return nil if a valid timeline can be created
   @return the timeline for combined results or nil if error
 */
- (NSArray *)combinedTimelineForOrderedRawResults:(NSArray *)rawResults
                                            types:(PWESResultsTypes *)types
                                            error:(NSError **)error;

/**
   @param types a PWESResultsTypes object for which a predicate will be created
   @return a predicate to filter an array with
 */
- (NSPredicate *)filterPredicateFromTypes:(PWESResultsTypes *)types;

/**
   @param type the results type
   @return a string to be used in a predicate
 */
- (NSString *)filterStringForType:(NSString *)type;

/**
   @param types an array of strings for which a predicate will be created
 */
- (NSPredicate *)filterForTypesArray:(NSArray *)resultsTypes;
@end
