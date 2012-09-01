//
//  ChartEvents.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 17/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChartEvents.h"
#import "Results.h"
#import "Medication.h"
#import "MissedMedication.h"
#import "ChartSettings.h"

@implementation ChartEvents
@synthesize allChartEvents = _allChartEvents;

- (id)init
{
    self = [super init];
    if (self)
    {
        NSMutableArray *tmpArray = [NSMutableArray array];
        self.allChartEvents = tmpArray;
    }
    return self;
}

- (void)sortEventsAscending:(BOOL)ascending
{
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:ascending];
    [self.allChartEvents sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];  
}


- (void)loadResult:(NSArray *)results
{
    if (nil == results)
    {
        return;
    }
    if (0 == [results count])
    {
        return;
    }
    for (Results *result in results)
    {
        ChartEvent *event = [[ChartEvent alloc] init];
        event.date = result.ResultsDate;
        if (0.0 < [result.CD4 floatValue])
        {
            event.CD4Count = result.CD4;
        }
        if (0.0 < [result.CD4Percent floatValue])
        {
            event.CD4Percent = result.CD4Percent;
        }
        if (0.0 <= [result.ViralLoad floatValue])
        {
            if (0.0 == [result.ViralLoad floatValue])
            {
                event.ViralLoad = [NSNumber numberWithFloat:2.0];
            }
            else
                event.ViralLoad = result.ViralLoad;
        }
        [self.allChartEvents addObject:event];
    }
}

- (void)loadMedication:(NSArray *)medications
{
    if (nil == medications)
    {
        return;
    }
    if (0 == [medications count])
    {
        return;
    }
    NSDate *previousDate = nil;
    for (Medication *medication in medications)
    {
        ChartEvent *event = [[ChartEvent alloc] init];
        event.date = medication.StartDate;
        event.medicationName = medication.Name;
        if (nil == previousDate)
        {
            [self.allChartEvents addObject:event];            
        }
        else{
            NSTimeInterval range = [event.date timeIntervalSinceDate:previousDate];
            if (TIMEINTERVAL < range)
            {
                [self.allChartEvents addObject:event];            
            }
        }
        previousDate = event.date;
    }
}

- (void)loadMissedMedication:(NSArray *)missedMedications
{
    if (nil == missedMedications)
    {
        return;
    }
    if (0 == [missedMedications count])
    {
        return;
    }
    for (MissedMedication *missedMedication in missedMedications)
    {
        ChartEvent *event = [[ChartEvent alloc] init];
        event.date = missedMedication.MissedDate;
        event.missedName = missedMedication.Name;
        [self.allChartEvents addObject:event];
    }
}



@end

@implementation ChartEvent
@synthesize date = _date;
@synthesize CD4Count = _CD4Count;
@synthesize CD4Percent = _CD4Percent;
@synthesize ViralLoad = _ViralLoad;
@synthesize medicationName = _medicationName;
@synthesize missedName = _missedName;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.date = nil;
        self.CD4Count = nil;
        self.CD4Percent = nil;
        self.ViralLoad = nil;
        self.medicationName = nil;
        self.missedName = nil;
    }
    return self;
}

@end
