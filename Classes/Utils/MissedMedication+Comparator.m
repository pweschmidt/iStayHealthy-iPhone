//
//  MissedMedication+Comparator.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 17/02/2013.
//
//

#import "MissedMedication+Comparator.h"

@implementation MissedMedication (Comparator)
- (BOOL)isEqualTo:(id)dataObject
{
    MissedMedication *missed = nil;
    if ([dataObject isKindOfClass:[MissedMedication class]])
    {
        missed = (MissedMedication *)dataObject;
    }
    else
    {
        return NO;
    }
    if ([self isEqual:missed])
    {
        return YES;
    }
    if ([self.UID isEqualToString:missed.UID])
    {
        return YES;
    }
    NSUInteger comparator = 2;
    NSUInteger index = 0;
    if ([self.MissedDate compare:missed.MissedDate] == NSOrderedSame)
    {
        index++;
    }
    if ([self.Name isEqualToString:missed.Name])
    {
        index++;
    }
    return (comparator == index) ? YES : NO;
}

@end
