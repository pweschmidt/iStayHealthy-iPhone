//
//  NSNumber+Handling.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "NSNumber+Handling.h"

@implementation NSNumber (Handling)
- (BOOL)hasValue
{
    if (!self || [self isKindOfClass:[NSNull class]] || 0 >= [self floatValue])
    {
        return NO;
    }
    return YES;
}
@end
