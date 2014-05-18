//
//  PWESDataTuple.m
//  HealthCharts
//
//  Created by Peter Schmidt on 27/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import "PWESDataTuple.h"

@interface PWESDataTuple ()
@property (nonatomic, strong, readwrite) NSArray *valueTuple;
@property (nonatomic, strong, readwrite) NSArray *dateTuple;
@property (nonatomic, strong, readwrite) NSString *type;
@end

@implementation PWESDataTuple
+ (PWESDataTuple *)resultsTupleWithResultsArray:(NSArray *)values dates:(NSArray *)dates type:(NSString *)type
{
	PWESDataTuple *tuple = [[PWESDataTuple alloc] init];
	tuple.valueTuple = values;
	tuple.dateTuple = dates;
	tuple.type = type;
	return tuple;
}

+ (PWESDataTuple *)medTupleWithMedicationArray:(NSArray *)medication
{
	PWESDataTuple *tuple = [[PWESDataTuple alloc] init];
	[tuple addMedTypeArray:medication dateType:kStartDate];
	tuple.type = kMedication;
	return tuple;
}

+ (PWESDataTuple *)missedMedTupleWithMissedMedicationArray:(NSArray *)medication
{
	PWESDataTuple *tuple = [[PWESDataTuple alloc] init];
	[tuple addMedTypeArray:medication dateType:kMissedDate];
	tuple.type = kMissedMedication;
	return tuple;
}

- (NSUInteger)length
{
	return self.valueTuple.count;
}

- (BOOL)isEmpty
{
	return (0 == self.valueTuple.count);
}

- (id)valueForDate:(id)date
{
	NSUInteger index = [self.dateTuple indexOfObject:date];
	if (index == NSNotFound)
	{
		return nil;
	}
	else
	{
		return [self.valueTuple objectAtIndex:index];
	}
}

#pragma mark private
- (void)addMedTypeArray:(NSArray *)medArray dateType:(NSString *)dateType
{
	if (nil == medArray || 0 == medArray.count)
	{
		self.valueTuple = [NSArray array];
		self.dateTuple = [NSArray array];
		return;
	}
	NSArray *dates = [medArray valueForKey:dateType];
	if (nil != dates)
	{
		self.dateTuple = dates;
	}
	else
	{
		self.dateTuple = [NSArray array];
	}

	NSArray *names = [medArray valueForKey:kName];
	if (nil != names)
	{
		self.valueTuple = names;
	}
	else
	{
		self.valueTuple = [NSArray array];
	}
}

@end
