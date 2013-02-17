//
//  Wellness+Comparator.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 17/02/2013.
//
//

#import "Wellness+Comparator.h"

@implementation Wellness (Comparator)
- (BOOL)isEqualTo:(id)dataObject
{
    Wellness *wellness = nil;
    if ([dataObject isKindOfClass:[Wellness class]])
    {
        wellness = (Wellness *)dataObject;
    }
    else
    {
        return NO;
    }
    if ([self isEqual:wellness])
    {
        return YES;
    }
    if ([self.uID isEqualToString:wellness.uID])
    {
        return YES;
    }
    return NO;
}

@end
