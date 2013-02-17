//
//  Contacts+Comparator.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 17/02/2013.
//
//

#import "Contacts+Comparator.h"

@implementation Contacts (Comparator)
- (BOOL)isEqualTo:(id)dataObject;
{
    Contacts *contacts = nil;
    if ([dataObject isKindOfClass:[Contacts class]])
    {
        contacts = (Contacts *)dataObject;
    }
    else
    {
        return NO;
    }
    if ([self isEqual:contacts])
    {
        return YES;
    }
    if ([self.UID isEqualToString:contacts.UID])
    {
        return YES;
    }
    if ([self.ClinicName isEqualToString:contacts.ClinicName])
    {
        return YES;
    }
    return NO;
}
@end
