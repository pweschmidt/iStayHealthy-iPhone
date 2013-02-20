//
//  Procedures+Comparator.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 17/02/2013.
//
//

#import "Procedures+Comparator.h"

@implementation Procedures (Comparator)
- (BOOL)isEqualTo:(id)dataObject
{
    Procedures *procedures = nil;
    if ([dataObject isKindOfClass:[Procedures class]])
    {
        procedures = (Procedures *)dataObject;
    }
    else
    {
        return NO;
    }
    if ([self isEqual:procedures])
    {
        return YES;
    }
    if ([self.UID isEqualToString:procedures.UID])
    {
        return YES;
    }
    NSUInteger comparator = 0;
    NSUInteger index = 0;

    comparator++;
    if ([self.Date compare:procedures.Date] == NSOrderedSame)
    {
        index++;
    }
    if (self.Name && procedures.Name)
    {
        comparator++;
        if ([self.Name isEqualToString:procedures.Name])
        {
            index++;
        }
    }
    if (self.Illness && procedures.Illness)
    {
        comparator++;
        if ([self.Illness isEqualToString:procedures.Illness])
        {
            index++;
        }
    }
    
    return (comparator == index) ? YES : NO;
}

@end
