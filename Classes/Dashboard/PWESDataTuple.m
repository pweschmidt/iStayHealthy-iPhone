//
//  PWESDataTuple.m
//  HealthCharts
//
//  Created by Peter Schmidt on 27/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//

#import "PWESDataTuple.h"

@interface PWESDataTuple ()
@property (nonatomic, strong, readwrite) NSArray * valueTuple;
@property (nonatomic, strong, readwrite) NSArray * dateTuple;
@property (nonatomic, strong, readwrite) NSString * type;
@end

@implementation PWESDataTuple
+(PWESDataTuple *)initWithValues:(NSArray *)values dates:(NSArray *)dates type:(NSString *)type
{
    PWESDataTuple * tuple = [[PWESDataTuple alloc] init];
    tuple.valueTuple = values;
    tuple.dateTuple = dates;
    tuple.type = type;
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
@end
