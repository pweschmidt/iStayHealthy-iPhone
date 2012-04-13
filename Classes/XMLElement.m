//
//  XMLElement.m
//  iStayHealthy
//
//  Created by peterschmidt on 13/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XMLElement.h"
#import "XMLAttribute.h"
#import "XMLDefinitions.h"

@implementation XMLElement
@synthesize name, value, attributes, childElements;
- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (id)initWithName:(NSString *)elementName{
    self = [self init];
    if (self) {
        nodeLevel = 0;
        self.name = elementName;
        value = @"";
        attributes = [[NSMutableArray alloc]initWithCapacity:0];
        childElements = [[NSMutableArray alloc]initWithCapacity:0];
    }
    NSLog(@"XMLElement::initWithName %@",elementName);
    return self;
}

- (void)addValue:(NSString *)valueText{
    self.value = valueText;
}

- (void)setNodeLevel:(int)level{
    nodeLevel = level;
}

- (void)addChild:(XMLElement *)element{
    [element setNodeLevel:(nodeLevel + 1)];
    [childElements addObject:element];
}

- (void)addAttribute:(NSString *)withName andValue:(NSString *)withValue{
    if (nil == withName || nil == withValue) {
        return;
    }
    XMLAttribute *attribute = [[XMLAttribute alloc]init];
    [attribute setName:withName];
    [attribute setValue:withValue];
    [attributes addObject:attribute];   
    [attribute release];
}

- (NSMutableString *)tabs{
    NSMutableString *tabString = [NSMutableString stringWithString:@""];
    for(int i = 0 ; i < nodeLevel ; i++ )
        [tabString appendString:@"\t"];
    
    return tabString;
}


- (NSMutableString *)toString{
    NSLog(@"toString elementName %@",name);
    NSMutableString *tabs = [self tabs];
    NSMutableString *xmlString = [NSMutableString stringWithFormat:@"\r%@<%@",tabs,name];
    if (0 < [attributes count] ) {
        for (NSObject *obj in attributes) {
            XMLAttribute *attribute = (XMLAttribute *)obj;
            [xmlString appendString:[attribute toString]];
        }
    }
    [xmlString appendString:@">\r"];
    if (0 < [childElements count]) {
        for (NSObject *obj in childElements) {
            XMLElement *child = (XMLElement *)obj;
            [xmlString appendString:[child toString]];
        }
    }
    else if ([value isEqualToString:@""]) {
            [xmlString appendFormat:@"\t%@",value];
    }
    [xmlString appendString:@"\r"];
    [xmlString appendFormat:@"%@</%@>",tabs,name];
    return xmlString;
}

/**
 */
- (NSString *)elementUID{
    NSString *uid = nil;
    for (XMLAttribute *attribute in attributes) {
        if ([attribute.name isEqualToString:@"UID"]) {
            if (![attribute.value isEqualToString:@""]) {
                uid = attribute.value;
            }
        }
    }
    return uid;
}

/**
 */
- (NSString *)attributeValue:(NSString *)forKey{
    NSString *attvalue = nil;
    for (XMLAttribute *attribute in attributes) {
        if ([attribute.name isEqualToString:forKey]) {
            if (![attribute.value isEqualToString:@""]) {
                attvalue = attribute.value;
            }
        }
    }
    return attvalue;
}


/**
 dealloc
 */
- (void)dealloc{
    [name release];
    [value release];
    [attributes release];
    [childElements release];
    [super dealloc];
}

@end
