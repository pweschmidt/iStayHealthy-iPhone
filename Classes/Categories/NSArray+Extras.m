//
//  NSArray+Extras.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 23/11/2013.
//
//

#import "NSArray+Extras.h"

@implementation NSArray (Extras)
- (NSNumber *)maxNumber
{
    if (0 == self.count)
    {
        return [NSNumber numberWithFloat:-1];
    }
    __block float max = -1;
    [self enumerateObjectsUsingBlock:^(NSNumber *number, NSUInteger idx, BOOL *stop) {
        float value = [number floatValue];
        if (value > max)
        {
            max = value;
        }
    }];
    return [NSNumber numberWithFloat:max];
}

- (NSNumber *)minNumber
{
    if (0 == self.count)
    {
        return [NSNumber numberWithFloat:-1];
    }
    __block float min = MAXFLOAT;
    [self enumerateObjectsUsingBlock:^(NSNumber *number, NSUInteger idx, BOOL *stop) {
        float value = [number floatValue];
        if (value < min)
        {
            min = value;
        }
    }];
    return [NSNumber numberWithFloat:min];    
}
@end
