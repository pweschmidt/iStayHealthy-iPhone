//
//  iStayHealthyRecord+Comparator.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 17/02/2013.
//
//

#import "iStayHealthyRecord+Comparator.h"

@implementation iStayHealthyRecord (Comparator)
- (BOOL)isEqualTo:(id)dataObject
{
    iStayHealthyRecord *record = nil;
    if ([dataObject isKindOfClass:[iStayHealthyRecord class]])
    {
        record = (iStayHealthyRecord *)dataObject;
    }
    else
    {
        return NO;
    }
    if ([self isEqual:record])
    {
        return YES;
    }
    NSUInteger comparator = 0;
    NSUInteger index = 0;
    
    if (self.UID && record.UID)
    {
        comparator++;
        if ([self.UID isEqualToString:record.UID])
        {
            index++;
        }
    }
    if (self.isPasswordEnabled && record.isPasswordEnabled)
    {
        comparator++;
        if ([self.isPasswordEnabled isEqualToNumber:record.isPasswordEnabled])
        {
            index++;
        }
    }
    
    return (comparator == index) ? YES : NO;
}

- (BOOL)isEmpty
{
    NSUInteger content = 0;
    content += self.results.count;
    content += self.wellness.count;
    content += self.medications.count;
    content += self.previousMedications.count;
    content += self.procedures.count;
    content += self.otherMedications.count;
    content += self.missedMedications.count;
    content += self.contacts.count;
    content += self.sideeffects.count;    
    return (0 == content) ? YES : NO;
}


@end
