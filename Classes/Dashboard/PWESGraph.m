//
//  PWESGraph.m
//  HealthCharts
//
//  Created by Peter Schmidt on 12/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import "PWESGraph.h"
#import "Results.h"
#import "Medication.h"
#import "Constants.h"

@interface PWESGraph ()
@property (nonatomic, strong, readwrite) NSArray * timeline;
@property (nonatomic, strong, readwrite) NSDictionary * graph;
@property (nonatomic, strong) NSArray *results;
@property (nonatomic, strong) NSArray *medications;
@end

@implementation PWESGraph
- (id)initWithRawResults:(NSArray *)results medications:(NSArray *)medications
{
    self = [super init];
    if (nil != self)
    {
        _results = results;
        _medications = medications;
    }
    return self;
}

- (void)createGraphForPredicate:(NSPredicate *)predicate
{
    __block NSMutableDictionary *chartMap = [NSMutableDictionary dictionary];
    __block NSMutableArray *timestamps = [NSMutableArray array];
    [self buildResultsGraphFromPredicate:predicate chartMap:chartMap timeline:timestamps];
    [self buildMedicationGraphFromPredicate:predicate chartMap:chartMap timeline:timestamps];
    
    if (0 < timestamps.count)
    {
        self.timeline = [timestamps sortedArrayUsingComparator:^NSComparisonResult(NSDate *date1, NSDate *date2) {
            return [date1 compare:date2];
        }];
    }
    else
    {
        self.timeline = [NSArray arrayWithArray:timestamps];
    }
    
    self.graph = [NSDictionary dictionaryWithDictionary:chartMap];
}

- (void)buildResultsGraphFromPredicate:(NSPredicate *)predicate
                              chartMap:(NSMutableDictionary *)chartMap
                              timeline:(NSMutableArray *)timeline
{
    NSArray *filteredResults = [self.results filteredArrayUsingPredicate:predicate];
    if (filteredResults && 0 < filteredResults.count)
    {
        NSArray *times = [filteredResults valueForKey:kResultsDate];
        if (times)
        {
            [times enumerateObjectsUsingBlock:^(NSDate *date, NSUInteger idx, BOOL *stop) {
                NSPredicate *timePredicate = [NSPredicate predicateWithFormat:@"ResultsDate == %@", date];
                NSArray *foundTimes = [filteredResults filteredArrayUsingPredicate:timePredicate];
                if (0 < foundTimes.count)
                {
                    Results *foundResult = [foundTimes objectAtIndex:0];
                    [chartMap setObject:foundResult forKey:date];
                    [timeline addObject:date];
                }
            }];
        }
    }
    
}

- (void)buildMedicationGraphFromPredicate:(NSPredicate *)predicate
                                 chartMap:(NSMutableDictionary *)chartMap
                                 timeline:(NSMutableArray *)timeline
{
    NSArray *filteredMeds = [self.medications valueForKey:kStartDate];
    if (filteredMeds && 0 < filteredMeds.count)
    {
        [filteredMeds enumerateObjectsUsingBlock:^(NSDate *date, NSUInteger idx, BOOL *stop) {
            NSPredicate *timePredicate = [NSPredicate predicateWithFormat:@"StartDate == %@", date];
            NSArray *foundTimes = [self.medications filteredArrayUsingPredicate:timePredicate];
            if (0 < foundTimes)
            {
                Medication *foundMed = [foundTimes objectAtIndex:0];
                [chartMap setObject:foundMed forKey:date];
                [timeline addObject:date];
            }
        }];
    }
}
@end
