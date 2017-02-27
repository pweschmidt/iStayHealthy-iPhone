//
//  PWESDataTuple.m
//  HealthCharts
//
//  Created by Peter Schmidt on 27/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import "PWESDataTuple.h"
#import "Medication.h"
#import "MissedMedication.h"
#import "PWESCalendar.h"

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
    [tuple addMeds:medication dateKey:kStartDate nameKey:kName];
//	[tuple addMedTypeArray:medication dateType:kStartDate];
	tuple.type = kMedication;
	return tuple;
}

+ (PWESDataTuple *)missedMedTupleWithMissedMedicationArray:(NSArray *)medication
{
	PWESDataTuple *tuple = [[PWESDataTuple alloc] init];
	[tuple addMeds:medication dateKey:kMissedDate nameKey:kName];
//	[tuple addMedTypeArray:medication dateType:kMissedDate];
	tuple.type = kMissedMedication;
	return tuple;
}

+ (PWESDataTuple *)previousMedTupleWithArray:(NSArray *)previous
{
    PWESDataTuple *tuple = [PWESDataTuple new];
    [tuple addMeds:previous dateKey:kStartDateLowerCase  nameKey:kNameLowerCase];
    tuple.type = kPreviousMedication;
    return tuple;
}

- (void)addAnotherMedicationTuple:(PWESDataTuple *)anotherMedTuple
{
    if(nil == anotherMedTuple.valueTuple || nil == anotherMedTuple.dateTuple)
    {
        return;
    }
    NSMutableArray *combinedValues = [NSMutableArray arrayWithArray:self.valueTuple];
    [combinedValues addObjectsFromArray:anotherMedTuple.valueTuple];
    NSMutableArray *combinedDates = [NSMutableArray arrayWithArray:self.dateTuple];
    [combinedDates addObjectsFromArray:anotherMedTuple.dateTuple];
    [combinedDates sortUsingSelector:@selector(compare:)];
    
    self.valueTuple = [NSArray arrayWithArray:combinedValues];
    self.dateTuple = [NSArray arrayWithArray:combinedDates];
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

- (void)addMeds:(NSArray *)meds dateKey:(NSString *)dateKey nameKey:(NSString *)nameKey
{
	if (nil == meds || 0 == meds.count)
	{
		self.valueTuple = [NSArray array];
		self.dateTuple = [NSArray array];
		return;
	}
	__block NSMutableArray *cleanedMeds = [NSMutableArray array];
	__block NSDate *previousDate = nil;
	[meds enumerateObjectsUsingBlock: ^(id medObject, NSUInteger idx, BOOL *stop) {
	    NSDate *date = [medObject valueForKey:dateKey];
	    if (nil != previousDate)
	    {
	        BOOL isWithinMargin = [[PWESCalendar sharedInstance] datesAreWithinDays:kDaysOfMedicationsMarginInPlot
	                                                                          date1:previousDate
	                                                                          date2:date];
	        if (!isWithinMargin)
	        {
	            [cleanedMeds addObject:medObject];
	            previousDate = date;
			}
		}
	    else
	    {
	        [cleanedMeds addObject:medObject];
	        previousDate = date;
		}
	}];
	if (0 < cleanedMeds.count)
	{
		self.valueTuple = [cleanedMeds valueForKey:nameKey];
		self.dateTuple = [cleanedMeds valueForKey:dateKey];
	}
	else
	{
		self.valueTuple = [NSArray array];
		self.dateTuple = [NSArray array];
	}
}



@end
