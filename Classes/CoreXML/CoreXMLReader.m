//
//  CoreXMLReader.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 10/08/2013.
//
//

#import "CoreXMLReader.h"

@interface CoreXMLReader ()
@property (nonatomic, strong, readwrite) NSString *filePath;
@property (nonatomic, strong, readwrite) NSMutableDictionary *xmlData;
@property (nonatomic, strong, readwrite) NSMutableArray *resultArray;
@property (nonatomic, strong, readwrite) NSMutableArray * medicationArray;
@property (nonatomic, strong, readwrite) NSArray * results;
@property (nonatomic, strong, readwrite) NSArray * medications;
@end

@implementation CoreXMLReader
+ (id) sharedInstance
{
    static CoreXMLReader *reader = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        reader = [[CoreXMLReader alloc] init];
    });
    return reader;
}

- (void)parseXMLData:(NSData *)xmlData
{
    if (nil == xmlData)
    {
        return;
    }
    NSData *data = [xmlData copy];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    [parser parse];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    NSLog(@"START PARSING");
}


- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    
}

@end
