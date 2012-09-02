//
//  XMLAttribute.m
//  iStayHealthy
//
//  Created by peterschmidt on 13/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XMLAttribute.h"
#import "XMLDefinitions.h"

@implementation XMLAttribute
@synthesize name = _name;
@synthesize value = _value;
- (id)init
{
    self = [super init];
    if (nil != self)
    {
        self.name = @"";
        self.value = @"";
    }
    
    return self;
}


-(NSString *)toString
{
    return [NSString stringWithFormat:@" %@=\"%@\"",self.name,self.value];
}



@end
