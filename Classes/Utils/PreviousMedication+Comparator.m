//
//  PreviousMedication+Comparator.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 17/02/2013.
//
//

#import "PreviousMedication+Comparator.h"

@implementation PreviousMedication (Comparator)
- (BOOL)isEqualTo:(id)dataObject
{
    PreviousMedication *previous = nil;
    if ([dataObject isKindOfClass:[PreviousMedication class]])
    {
        previous = (PreviousMedication *)dataObject;
    }
    else
    {
        return NO;
    }
    if ([self isEqual:previous])
    {
        return YES;
    }
    if ([self.uID isEqualToString:previous.uID])
    {
        return YES;
    }
    NSUInteger comparator = 3;
    NSUInteger index = 0;
    if ([self.startDate compare:previous.startDate] == NSOrderedSame)
    {
        index++;
    }
    if ([self.endDate compare:previous.endDate] == NSOrderedSame)
    {
        index++;
    }
    if ([self.name isEqualToString:previous.name])
    {
        index++;
    }
    return (comparator == index) ? YES : NO;
}

@end
