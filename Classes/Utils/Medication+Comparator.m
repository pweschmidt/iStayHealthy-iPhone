//
//  Medication+Comparator.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 17/02/2013.
//
//

#import "Medication+Comparator.h"

@implementation Medication (Comparator)
- (BOOL)isEqualTo:(id)dataObject
{
    Medication *medication = nil;
    if ([dataObject isKindOfClass:[Medication class]])
    {
        medication = (Medication *)dataObject;
    }
    else
    {
        return NO;
    }
    if ([self isEqual:medication])
    {
        return YES;
    }
    if ([self.UID isEqualToString:medication.UID])
    {
        return YES;
    }
    NSUInteger comparator = 2;
    NSUInteger index = 0;
    if ([self.StartDate compare:medication.StartDate] == NSOrderedSame)
    {
        index++;
    }
    if ([self.Name isEqualToString:medication.Name])
    {
        index++;
    }
    return (comparator == index) ? YES : NO;
}
@end
