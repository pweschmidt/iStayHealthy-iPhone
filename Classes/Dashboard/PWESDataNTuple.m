//
//  PWESDataNTuple.m
//  HealthCharts
//
//  Created by Peter Schmidt on 27/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import "PWESDataNTuple.h"
#import "PWESDataManager.h"

@interface PWESDataNTuple ()
@property (nonatomic, strong, readwrite) NSArray *dateLine;
@property (nonatomic, strong, readwrite) NSMutableArray *resultTypes;
@property (nonatomic, strong, readwrite) PWESDataTuple *medicationTuple;
@property (nonatomic, strong, readwrite) PWESDataTuple *missedMedicationTuple;
@property (nonatomic, strong) NSMutableDictionary *tuples;
@property (nonatomic, strong, readwrite) NSDate *firstResultsDate;
@property (nonatomic, strong, readwrite) NSDate *lastResultsDate;
@property (nonatomic, assign, readwrite) NSUInteger maxNumberOfResults;
@end

@implementation PWESDataNTuple
+ (PWESDataNTuple *)nTupleWithRawResults:(NSArray *)rawResults
                          rawMedications:(NSArray *)rawMedications
                    rawMissedMedications:(NSArray *)rawMissedMedications
                                   types:(PWESResultsTypes *)types
                                   error:(NSError **)error
{
	if (nil == rawResults || nil == types)
	{
		if (NULL != error)
		{
			*error = [NSError errorWithDomain:@"com.pweschmidt.healthcharts" code:100 userInfo:nil];
		}
		return nil;
	}

	PWESDataNTuple *ntuple = [[PWESDataNTuple alloc] init];
	ntuple.maxNumberOfResults = 0;
	[ntuple createTuplesForResults:rawResults types:types];
	if (types.isDualType)
	{
		ntuple.dateLine = [[PWESDataManager sharedInstance]
		                   combinedTimelineForOrderedRawResults:rawResults
		                                                  types:types
		                                                  error:error];
	}
	else
	{
		PWESDataTuple *onlyTuple = [ntuple.tuples objectForKey:types.mainType];
		ntuple.dateLine = onlyTuple.dateTuple;
	}

	if (nil != rawMedications && 0 < rawMedications.count)
	{
		PWESDataTuple *medTuple = [PWESDataTuple medTupleWithMedicationArray:rawMedications];
		[ntuple addMedicationTuple:medTuple];
	}

	if (nil != rawMissedMedications && 0 < rawMissedMedications.count)
	{
		PWESDataTuple *medTuple = [PWESDataTuple missedMedTupleWithMissedMedicationArray:rawMissedMedications];
		[ntuple addMissedMedicationTuple:medTuple];
	}

	return ntuple;
}

+ (PWESDataNTuple *)nTupleWithRawResults:(NSArray *)rawResults
                          rawMedications:(NSArray *)rawMedications
                  rawPreviousMedications:(NSArray *)rawPreviousMedications
                    rawMissedMedications:(NSArray *)rawMissedMedications
                                   types:(PWESResultsTypes *)types
                                   error:(NSError **)error
{
    if (nil == rawResults || nil == types)
    {
        if (NULL != error)
        {
            *error = [NSError errorWithDomain:@"com.pweschmidt.healthcharts" code:100 userInfo:nil];
        }
        return nil;
    }
    
    PWESDataNTuple *ntuple = [[PWESDataNTuple alloc] init];
    ntuple.maxNumberOfResults = 0;
    [ntuple createTuplesForResults:rawResults types:types];
    if (types.isDualType)
    {
        ntuple.dateLine = [[PWESDataManager sharedInstance]
                           combinedTimelineForOrderedRawResults:rawResults
                           types:types
                           error:error];
    }
    else
    {
        PWESDataTuple *onlyTuple = [ntuple.tuples objectForKey:types.mainType];
        ntuple.dateLine = onlyTuple.dateTuple;
    }
    
    if (nil != rawMedications && 0 < rawMedications.count)
    {
        PWESDataTuple *medTuple = [PWESDataTuple medTupleWithMedicationArray:rawMedications];
        [ntuple addMedicationTuple:medTuple];
    }
    
    if (nil != rawMissedMedications && 0 < rawMissedMedications.count)
    {
        PWESDataTuple *medTuple = [PWESDataTuple missedMedTupleWithMissedMedicationArray:rawMissedMedications];
        [ntuple addMissedMedicationTuple:medTuple];
    }
    
    if (nil != rawPreviousMedications && 0 < rawPreviousMedications.count)
    {
        PWESDataTuple *medTuple = [PWESDataTuple previousMedTupleWithArray:rawPreviousMedications];
        [ntuple addPreviousMedicationTuple:medTuple];
    }
    
    
    return ntuple;
    
}


+ (PWESDataNTuple *)nTupleWithRawResults:(NSArray *)rawResults
                                   types:(PWESResultsTypes *)types
                                   error:(NSError **)error
{
	return [PWESDataNTuple nTupleWithRawResults:rawResults
	                             rawMedications:nil
	                       rawMissedMedications:nil
	                                      types:types error:error];
}

+ (PWESDataNTuple *)nTupleWithRawResults:(NSArray *)rawResults types:(PWESResultsTypes *)types
{
	PWESDataNTuple *ntuple = [[PWESDataNTuple alloc] init];
	NSError *error = nil;
	ntuple.maxNumberOfResults = rawResults.count;
	ntuple.dateLine = [[PWESDataManager sharedInstance]
	                   combinedTimelineForOrderedRawResults:rawResults
	                                                  types:types
	                                                  error:&error];
	return ntuple;
}

- (id)init
{
	self = [super init];
	if (nil != self)
	{
		_tuples = [NSMutableDictionary dictionary];
		_resultTypes = [NSMutableArray array];
	}
	return self;
}

- (void)addResultsTuple:(PWESDataTuple *)tuple
{
	[self.resultTypes addObject:tuple.type];
	[self.tuples setObject:tuple forKey:tuple.type];
	if (![tuple isEmpty])
	{
		NSDate *first = [tuple.dateTuple objectAtIndex:0];
		NSDate *last = [tuple.dateTuple lastObject];
		if (nil == self.firstResultsDate || NULL == self.firstResultsDate || [NSNull class] == self.firstResultsDate)
		{
			self.firstResultsDate = first;
		}
		else if (NSOrderedDescending == [self.firstResultsDate compare:first])
		{
			self.firstResultsDate = first;
		}
		if (nil == self.lastResultsDate || NULL == self.firstResultsDate || [NSNull class] == self.lastResultsDate)
		{
			self.lastResultsDate = last;
		}
		else if (NSOrderedAscending == [self.lastResultsDate compare:last])
		{
			self.lastResultsDate = last;
		}
		NSUInteger count = tuple.dateTuple.count;
		if (self.maxNumberOfResults < count)
		{
			self.maxNumberOfResults = count;
		}
	}
}

- (void)addMissedMedicationTuple:(PWESDataTuple *)missedTuple
{
	self.missedMedicationTuple = missedTuple;
	[self addTupleToDateLine:missedTuple];
}

- (void)addMedicationTuple:(PWESDataTuple *)medTuple
{
	self.medicationTuple = medTuple;
	[self addTupleToDateLine:medTuple];
}

- (void)addPreviousMedicationTuple:(PWESDataTuple *)previousTuple
{
    if (nil == self.medicationTuple || nil == self.medicationTuple.valueTuple || nil == self.medicationTuple.dateTuple) {
        self.medicationTuple = previousTuple;
    }
    [self.medicationTuple addAnotherMedicationTuple:previousTuple];    
    [self addTupleToDateLine:previousTuple];
}


- (PWESDataTuple *)resultsTupleForType:(NSString *)type
{
	return [self.tuples objectForKey:type];
}

- (NSUInteger)length
{
	return self.tuples.count;
}

- (BOOL)isEmpty
{
	return (0 == self.dateLine.count);
}

- (BOOL)hasResults
{
	__block BOOL hasResultsForTuples = NO;
	if (nil == self.tuples || 0 == self.tuples.allKeys.count)
	{
		return NO;
	}
	[self.tuples enumerateKeysAndObjectsUsingBlock: ^(id key, PWESDataTuple *tuple, BOOL *stop) {
	    if (![tuple isEmpty])
	    {
	        hasResultsForTuples = YES;
	        *stop = YES;
		}
	}];
	return hasResultsForTuples;
}

#pragma mark private methods
- (void)createTuplesForResults:(NSArray *)rawResults types:(PWESResultsTypes *)types
{
	NSError *error = nil;
	PWESDataTuple *tuple = [[PWESDataManager sharedInstance]
	                        filterOrderedRawResults:rawResults
	                                           type:types.mainType
	                                          error:&error];
	if (!error)
	{
		[self addResultsTuple:tuple];
	}
	else
	{
		return;
	}
	if (types.isDualType)
	{
		PWESDataTuple *secondTuple = [[PWESDataManager sharedInstance]
		                              filterOrderedRawResults:rawResults
		                                                 type:types.secondaryType
		                                                error:&error];
		if (!error)
		{
			[self addResultsTuple:secondTuple];
		}
	}
}

- (void)addTupleToDateLine:(PWESDataTuple *)tuple
{
	if (0 == tuple.length)
	{
		return;
	}
	NSArray *dates = tuple.dateTuple;
	NSMutableArray *array = [NSMutableArray arrayWithArray:self.dateLine];
	[array addObjectsFromArray:dates];
	[array sortUsingSelector:@selector(compare:)];
	self.dateLine = [NSArray arrayWithArray:array];
}

@end
