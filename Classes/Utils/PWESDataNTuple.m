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
@property (nonatomic, strong, readwrite) NSArray * dateLine;
@property (nonatomic, strong, readwrite) NSMutableArray * types;
@property (nonatomic, strong) NSMutableDictionary * tuples;
@end

@implementation PWESDataNTuple

+ (PWESDataNTuple *)initWithRawResults:(NSArray *)rawResults
                                 types:(NSArray *)types
                                 error:(NSError **)error
{
    if (nil == rawResults || nil == types || 0 == types.count)
    {
        *error = [NSError errorWithDomain:@"com.pweschmidt.healthcharts" code:100 userInfo:nil];
        return nil;
    }
    
    PWESDataNTuple *ntuple = [[PWESDataNTuple alloc] init];
    [ntuple createTuplesForResults:rawResults types:types];
    if (1 < types.count)
    {
        ntuple.dateLine = [[PWESDataManager sharedInstance]
                           combinedTimelineForOrderedRawResults:rawResults
                           types:types
                           error:error];
    }
    else
    {
        PWESDataTuple *onlyTuple = [ntuple.tuples objectForKey:[types objectAtIndex:0]];
        ntuple.dateLine = onlyTuple.dateTuple;
    }
    return ntuple;
}


+ (PWESDataNTuple *)initWithRawResults:(NSArray *)rawResults types:(NSArray *)types
{
    PWESDataNTuple *ntuple = [[PWESDataNTuple alloc] init];
    NSError *error = nil;
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
        _types = [NSMutableArray array];
    }
    return self;
}

- (void)addDataTuple:(PWESDataTuple *)tuple
{
    [self.types addObject:tuple.type];
    [self.tuples setObject:tuple forKey:tuple.type];
}

- (PWESDataTuple *)tupleForType:(NSString *)type
{
    return [self.tuples objectForKey:type];
}

- (NSUInteger)length
{
    return self.tuples.count;
}

- (BOOL)isEmpty
{
    return (0 == self.tuples.count);
}

#pragma mark private methods
- (void)createTuplesForResults:(NSArray *)rawResults types:(NSArray *)types
{
    for (NSString *type in types)
    {
        NSError *error = nil;
        PWESDataTuple *tuple = [[PWESDataManager sharedInstance]
                                filterOrderedRawResults:rawResults
                                type:type
                                error:&error];
        if (!error)
        {
            [self addDataTuple:tuple];
        }
    }
}

@end
