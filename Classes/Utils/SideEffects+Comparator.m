//
//  SideEffects+Comparator.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 17/02/2013.
//
//

#import "SideEffects+Comparator.h"

@implementation SideEffects (Comparator)
- (BOOL)isEqualTo:(id)dataObject
{
    SideEffects *sideEffects = nil;
    if ([dataObject isKindOfClass:[SideEffects class]])
    {
        sideEffects = (SideEffects *)dataObject;
    }
    else
    {
        return NO;
    }
    if ([self isEqual:sideEffects])
    {
        return YES;
    }
    if ([self.UID isEqualToString:sideEffects.UID])
    {
        return YES;
    }
    NSUInteger comparator = 0;
    NSUInteger index = 0;

    comparator++;
    if ([self.SideEffectDate compare:sideEffects.SideEffectDate] == NSOrderedSame)
    {
        index++;
    }

    comparator++;
    if ([self.SideEffect isEqualToString:sideEffects.SideEffect])
    {
        index++;
    }
    
    if (self.Name && sideEffects.Name)
    {
        comparator++;
        if ([self.Name isEqualToString:sideEffects.Name])
        {
            index++;
        }
    }
    if (self.Drug && sideEffects.Drug)
    {
        comparator++;
        if ([self.Drug isEqualToString:sideEffects.Drug])
        {
            index++;
        }
    }
    if (self.seriousness && sideEffects.seriousness)
    {
        comparator++;
        if ([self.seriousness isEqualToString:sideEffects.seriousness])
        {
            index++;
        }
    }
    return (comparator == index) ? YES : NO;
}

@end
