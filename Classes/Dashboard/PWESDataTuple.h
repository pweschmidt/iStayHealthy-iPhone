//
//  PWESDataTuple.h
//  HealthCharts
//
//  Created by Peter Schmidt on 27/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PWESDataTuple : NSObject
@property (nonatomic, strong, readonly) NSArray *valueTuple;
@property (nonatomic, strong, readonly) NSArray *dateTuple;
@property (nonatomic, strong, readonly) NSString *type;

+ (PWESDataTuple *)resultsTupleWithResultsArray:(NSArray *)values dates:(NSArray *)dates type:(NSString *)type;

+ (PWESDataTuple *)medTupleWithMedicationArray:(NSArray *)medication;

+ (PWESDataTuple *)missedMedTupleWithMissedMedicationArray:(NSArray *)medication;

+ (PWESDataTuple *)previousMedTupleWithArray:(NSArray *)previous;

- (NSUInteger)length;

- (BOOL)isEmpty;

- (id)valueForDate:(id)date;

- (void)addAnotherMedicationTuple:(PWESDataTuple *)anotherMedTuple;

@end
