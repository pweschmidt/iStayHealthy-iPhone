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

@interface PWESDataManager : NSObject

/**
 returns a singleton for PWESDataManager
 */
+ (id) sharedInstance;

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
 @param types an array of String types
 @param error will return nil if a valid timeline can be created
 @return the timeline for combined results or nil if error
 */
- (NSArray *)combinedTimelineForOrderedRawResults:(NSArray *)rawResults
                                                  types:(NSArray *)types
                                                  error:(NSError **)error;
@end