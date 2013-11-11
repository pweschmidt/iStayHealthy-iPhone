//
//  CoreXMLReader.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 10/08/2013.
//
//

#import "CoreXMLReader.h"
#import "Results+Handling.h"
#import "Medication+Handling.h"
#import "MissedMedication+Handling.h"
#import "OtherMedication+Handling.h"
#import "PreviousMedication+Handling.h"
#import "Procedures+Handling.h"
#import "SideEffects+Handling.h"
#import "iStayHealthyRecord+Handling.h"
#import "Wellness+Handling.h"
#import "Contacts+Handling.h"
#import "Constants.h"
#import "CoreDataManager.h"

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
    NSError *saveError = nil;
    [[CoreDataManager sharedInstance] saveContext:&saveError];
    if (nil  != saveError)
    {
        NSLog(@"END PARSING WITH ERROR");
        ///TODO handle error after we imported data
    }
    NSLog(@"END PARSING");
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    if(qName)
    {
		elementName = qName;
	}
    if ([elementName isEqualToString:kResult]) {
        Results *results = [[CoreDataManager sharedInstance]
                            managedObjectForEntityName:kResults];
        [results importFromDictionary:attributeDict];
    }
    else if ([elementName isEqualToString:kSideEffects])
    {
        SideEffects *effects = [[CoreDataManager sharedInstance]
                                managedObjectForEntityName:kSideEffects];
        [effects importFromDictionary:attributeDict];
        
    }
    else if ([elementName isEqualToString:kMedication])
    {
        Medication *med = [[CoreDataManager sharedInstance]
                           managedObjectForEntityName:kMedication];
        [med importFromDictionary:attributeDict];
        
    }
    else if ([elementName isEqualToString:kMissedMedication])
    {
        MissedMedication *missedMed = [[CoreDataManager sharedInstance]
                                       managedObjectForEntityName:kMissedMedication];
        [missedMed importFromDictionary:attributeDict];
        
    }
    else if ([elementName isEqualToString:kOtherMedication])
    {
        OtherMedication *otherMed = [[CoreDataManager sharedInstance]
                                     managedObjectForEntityName:kOtherMedication];
        [otherMed importFromDictionary:attributeDict];
        
    }
    else if ([elementName isEqualToString:kContacts])
    {
        Contacts *contacts = [[CoreDataManager sharedInstance]
                              managedObjectForEntityName:kContacts];
        [contacts importFromDictionary:attributeDict];
    }
    else if ([elementName isEqualToString:kProcedures])
    {
        Procedures *procedures = [[CoreDataManager sharedInstance]
                                  managedObjectForEntityName:kProcedures];
        [procedures importFromDictionary:attributeDict];
        
    }
    else if ([elementName isEqualToString:kPreviousMedication])
    {
        PreviousMedication *prevMed = [[CoreDataManager sharedInstance]
                                       managedObjectForEntityName:kPreviousMedication];
        [prevMed importFromDictionary:attributeDict];
        
    }
    else if ([elementName isEqualToString:kWellness])
    {
        Wellness *wellness = [[CoreDataManager sharedInstance]
                              managedObjectForEntityName:kWellness];
        [wellness importFromDictionary:attributeDict];
    }
    
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    ///TODO handle error apart from writing a DEBUG msg
#ifdef APPDEBUG
    NSLog(@"Error occurred while parsing XML file");
#endif
}

@end
