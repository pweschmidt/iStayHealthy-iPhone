//
//  PWESDataNTuple.h
//  HealthCharts
//
//  Created by Peter Schmidt on 27/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PWESDataTuple.h"

@interface PWESDataNTuple : NSObject
@property (nonatomic, strong, readonly) NSArray *dateLine;
@property (nonatomic, strong, readonly) NSMutableArray *resultTypes;
@property (nonatomic, strong, readonly) PWESDataTuple *medicationTuple;
@property (nonatomic, strong, readonly) PWESDataTuple *missedMedicationTuple;

/**
   initialises the tuple with rawresults and types
   a combined dateLine is created
   @param rawResults
   @param rawMedications
   @param rawMissedMedications
   @param array of NSString types. Must not be nil and have at least 1 entry
   @param error returns nil if an object can be created
   @return an ntuple or nil if error
 */
+ (PWESDataNTuple *)nTupleWithRawResults:(NSArray *)rawResults
                          rawMedications:(NSArray *)rawMedications
                    rawMissedMedications:(NSArray *)rawMissedMedications
                                   types:(NSArray *)types
                                   error:(NSError **)error;

/**
   initialises the tuple with rawresults and types
   a combined dateLine is created
   @param rawResults
   @param array of NSString types. Must not be nil and have at least 1 entry
   @param error returns nil if an object can be created
   @return an ntuple or nil if error
 */
+ (PWESDataNTuple *)nTupleWithRawResults:(NSArray *)rawResults
                                   types:(NSArray *)types
                                   error:(NSError **)error;

/**
   initialises the tuple with rawresults and types
   a combined dateLine is created. This only creates the combined dateline. It does not add
   the tuples
   @param rawResults
   @param array of NSString types. Must not be nil and have at least 1 entry
   @return an ntuple
 */
+ (PWESDataNTuple *)nTupleWithRawResults:(NSArray *)rawResults
                                   types:(NSArray *)types;
/**
   adds a data  tuple to the N-Tuple
   @param tuple
 */
- (void)addResultsTuple:(PWESDataTuple *)tuple;

/**
   adds a medication tuple to the N-Tuple
   @param medTuple
 */
- (void)addMedicationTuple:(PWESDataTuple *)medTuple;

/**
   adds a missed medication tuple to the N-Tuple
   @param missedTuple
 */
- (void)addMissedMedicationTuple:(PWESDataTuple *)missedTuple;

/**
   @param type the desired tuple type
   @return the tuple or nil if not found
 */
- (PWESDataTuple *)resultsTupleForType:(NSString *)type;

/**
   total length of the n-tuple
 */
- (NSUInteger)length;

/**
   @return YES if empty
 */
- (BOOL)isEmpty;
@end
