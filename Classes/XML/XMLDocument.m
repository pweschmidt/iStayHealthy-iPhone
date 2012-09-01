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
@synthesize root;
- (id)init
{
    self = [super init];
    if (self) {
        NSLog(@"initializing XMLDocument");
        root = [[XMLElement alloc]initWithName:ROOT];
        [root setNodeLevel:0];
    }
    
    return self;
}

-(NSMutableString *)xmlString{
    [root addAttribute:DBVERSION andValue:@"13"];
    [root addAttribute:FROMDEVICE andValue:[[UIDevice currentDevice]model]];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"dd-MMM-YY HH:mm:ss";
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    [root addAttribute:FROMDATE andValue:dateString];
    NSMutableString *xml = [NSMutableString stringWithString:XMLPREAMBLE];
    NSString *elementText = [root toString];
    [xml appendFormat:@"\r%@",elementText];
    return xml;
}

-(XMLElement *)elementForName:(NSString *)name{
    XMLElement *foundElement = nil;
    NSMutableArray *children = [root childElements];
    for (XMLElement *child in children) {
        if ([child.name isEqualToString:name]) {
            foundElement = child;
        }
    }
    return foundElement;    
}

/**
 
 */


@end
