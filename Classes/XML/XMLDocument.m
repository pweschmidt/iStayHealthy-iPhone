//
//  XMLDocument.m
//  iStayHealthy
//
//  Created by peterschmidt on 13/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XMLDocument.h"
#import "XMLElement.h"
#import "XMLDefinitions.h"

@implementation XMLDocument
@synthesize root = _root;
- (id)init
{
    self = [super init];
    if (nil != self)
    {
        NSLog(@"initializing XMLDocument");
        self.root = [[XMLElement alloc]initWithName:ROOT];
        self.root.nodeLevel = 0;
    }
    
    return self;
}

-(NSMutableString *)xmlString
{
    [self.root addAttribute:DBVERSION andValue:@"13"];
    [self.root addAttribute:FROMDEVICE andValue:[[UIDevice currentDevice]model]];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"dd-MMM-YY HH:mm:ss";
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    [self.root addAttribute:FROMDATE andValue:dateString];
    NSMutableString *xml = [NSMutableString stringWithString:XMLPREAMBLE];
    NSString *elementText = [self.root toString];
    [xml appendFormat:@"\r%@",elementText];
    return xml;
}

-(XMLElement *)elementForName:(NSString *)name
{
    XMLElement *foundElement = nil;
    NSMutableArray *children = [self.root childElements];
    for (XMLElement *child in children)
    {
        if ([child.name isEqualToString:name])
        {
            foundElement = child;
        }
    }
    return foundElement;    
}

/**
 
 */


@end
