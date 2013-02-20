//
//  OtherMedication+Comparator.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 17/02/2013.
//
//

#import "OtherMedication+Comparator.h"

@implementation OtherMedication (Comparator)
- (BOOL)isEqualTo:(id)dataObject
{
    OtherMedication *other = nil;
    if ([dataObject isKindOfClass:[OtherMedication class]])
    {
        other = (OtherMedication *)dataObject;
    }
    else
    {
        return NO;
    }
    if ([self isEqual:other])
    {
        return YES;
    }
    if ([self.UID isEqualToString:other.UID])
    {
        return YES;
    }
    NSUInteger comparator = 0;
    NSUInteger index = 0;

    comparator++;
    if ([self.StartDate compare:other.StartDate] == NSOrderedSame)
    {
        index++;
    }

    comparator++;
    if ([self.Name isEqualToString:other.Name])
    {
        index++;
    }

    if (other.Dose && self.Dose)
    {
        comparator++;
        if ([self.Dose isEqualToNumber:other.Dose])
        {
            index++;
        }
    }

    if (other.Unit && self.Unit)
    {
        comparator++;
        if ([self.Unit isEqualToString:other.Unit])
        {
            index++;
        }
    }
    
    
    return (comparator == index) ? YES : NO;
}

@end
