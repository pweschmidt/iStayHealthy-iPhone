//
//  XMLElement.m
//  iStayHealthy
//
//  Created by peterschmidt on 13/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XMLElement.h"
#import "XMLAttribute.h"
//#import "XMLDefinitions.h"

@implementation XMLElement
@synthesize name = _name;
@synthesize value = _value;
@synthesize attributes = _attributes;
@synthesize childElements = _childElements;
@synthesize nodeLevel = _nodeLevel;

- (id)init
{
    self = [super init];
    if (self)
    {
    }
    
    return self;
}

- (id)initWithName:(NSString *)elementName
{
    self = [self init];
    if (nil != self)
    {
        self.nodeLevel = 0;
        self.name = elementName;
        self.value = @"";
        self.attributes = [[NSMutableArray alloc]initWithCapacity:0];
        self.childElements = [[NSMutableArray alloc]initWithCapacity:0];
    }
    NSLog(@"XMLElement::initWithName %@",elementName);
    return self;
}

- (void)addValue:(NSString *)valueText
{
    self.value = valueText;
}


- (void)addChild:(XMLElement *)element
{
    element.nodeLevel = self.nodeLevel + 1;
    [self.childElements addObject:element];
}

- (void)addAttribute:(NSString *)withName andValue:(NSString *)withValue
{
    if (nil == withName || nil == withValue)
    {
        return;
    }
    XMLAttribute *attribute = [[XMLAttribute alloc]init];
    [attribute setName:withName];
    [attribute setValue:withValue];
    [self.attributes addObject:attribute];   
}

- (NSMutableString *)tabs
{
    NSMutableString *tabString = [NSMutableString stringWithString:@""];
    for(int i = 0 ; i < self.nodeLevel ; i++ )
        [tabString appendString:@"\t"];
    
    return tabString;
}


- (NSMutableString *)toString
{
    NSLog(@"toString elementName %@",self.name);
    NSMutableString *tabs = [self tabs];
    NSMutableString *xmlString = [NSMutableString stringWithFormat:@"\r%@<%@",tabs,self.name];
    if (0 < [self.attributes count] )
    {
        for (NSObject *obj in self.attributes)
        {
            XMLAttribute *attribute = (XMLAttribute *)obj;
            [xmlString appendString:[attribute toString]];
        }
    }
    [xmlString appendString:@">\r"];
    if (0 < [self.childElements count])
    {
        for (NSObject *obj in self.childElements)
        {
            XMLElement *child = (XMLElement *)obj;
            [xmlString appendString:[child toString]];
        }
    }
    else if ([self.value isEqualToString:@""])
    {
            [xmlString appendFormat:@"\t%@",self.value];
    }
    [xmlString appendString:@"\r"];
    [xmlString appendFormat:@"%@</%@>",tabs,self.name];
    return xmlString;
}

/**
 */
- (NSString *)elementUID
{
    NSString *uid = nil;
    for (XMLAttribute *attribute in self.attributes)
    {
        if ([attribute.name isEqualToString:@"UID"] || [attribute.name isEqualToString:@"uID"] || [attribute.name isEqualToString:@"GUID"])
        {
            if (![attribute.value isEqualToString:@""])
            {
                uid = attribute.value;
            }
        }
    }
    return uid;
}

/**
 */
- (NSString *)attributeValue:(NSString *)forKey
{
    NSString *attvalue = nil;
    for (XMLAttribute *attribute in self.attributes)
    {
        if ([attribute.name isEqualToString:forKey])
        {
            if (![attribute.value isEqualToString:@""])
            {
                attvalue = attribute.value;
            }
        }
    }
    return attvalue;
}


/**
 dealloc
 */

@end
