//
//  CoreDataManagerPlaceholder.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/08/2013.
//
//

#import "CoreDataManagerPlaceholder.h"
#import "CoreDataManageriOS6.h"
#import "CoreDataManageriOS7.h"

@implementation CoreDataManagerPlaceholder
- (id)init
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        return (id)[[CoreDataManageriOS6 alloc] init];
    }
    else
    {
        return (id)[[CoreDataManageriOS7 alloc] init];
    }
}
@end
