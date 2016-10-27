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
// #import "CoreDataManager.h"
#import "CoreXMLTools.h"
#import "iStayHealthy-Swift.h"

@interface CoreXMLReader ()
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSMutableDictionary *xmlData;
@property (nonatomic, strong) iStayHealthyRecord *masterRecord;
@property (nonatomic, strong) NSArray *results;
@property (nonatomic, strong) NSArray *medications;
@property (nonatomic, strong) NSArray *missed;
@property (nonatomic, strong) NSArray *previous;
@property (nonatomic, strong) NSArray *other;
@property (nonatomic, strong) NSArray *effects;
@property (nonatomic, strong) NSArray *procedures;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSArray *wellnesses;
@property (nonatomic, strong) iStayHealthySuccessBlock successBlock;

@end

@implementation CoreXMLReader

- (BOOL)hasContentForXMLWithPath:(NSString *)filePath;
{

    if (nil == filePath)
    {
        return NO;
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:filePath])
    {
        return NO;
    }
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSError *error = nil;
    NSData *cleanedData = [self validXMLDataForData:data error:&error];
    if (nil == cleanedData)
    {
        return NO;
    }
    NSString *xmlString = [[NSString alloc] initWithData:cleanedData encoding:NSUTF8StringEncoding];
    NSArray *results = [xmlString componentsSeparatedByString:@"<Result "];
    NSArray *meds = [xmlString componentsSeparatedByString:@"<Medication "];
    NSArray *missed = [xmlString componentsSeparatedByString:@"<MissedMedication "];
    NSArray *other = [xmlString componentsSeparatedByString:@"<OtherMedication "];
    NSArray *procs = [xmlString componentsSeparatedByString:@"<Procedures "];
    NSArray *contacts = [xmlString componentsSeparatedByString:@"<Contacts "];
    NSArray *effects = [xmlString componentsSeparatedByString:@"<SideEffects "];

    BOOL hasContent = NO;
    if (1 < results.count)
    {
        hasContent = YES;
    }
    else if (1 < meds.count)
    {
        hasContent = YES;
    }
    else if (1 < missed.count)
    {
        hasContent = YES;
    }
    else if (1 < other.count)
    {
        hasContent = YES;
    }
    else if (1 < procs.count)
    {
        hasContent = YES;
    }
    else if (1 < contacts.count)
    {
        hasContent = YES;
    }
    else if (1 < effects.count)
    {
        hasContent = YES;
    }

    return NO;
}


- (void)parseXMLData:(NSData *)xmlData
     completionBlock:(iStayHealthySuccessBlock)completionBlock
{
    if (nil == xmlData)
    {
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : @"XML must not be nil" };
        NSError *error = [NSError errorWithDomain:@"com.iStayHealthy" code:100 userInfo:userInfo];
        if (completionBlock)
        {
            completionBlock(NO, error);
        }
        return;
    }
    self.successBlock = completionBlock;
    NSData *data = [xmlData copy];
    NSError *error = nil;
    NSData *cleanedData = [self validXMLDataForData:data error:&error];
    if (nil == cleanedData)
    {
        if (completionBlock)
        {
            completionBlock(NO, error);
        }
        return;
    }
#ifdef APPDEBUG
    NSString *xmlString = [[NSString alloc] initWithData:cleanedData encoding:NSUTF8StringEncoding];
    NSLog(@"**** XMLString \r\n %@ \r\n ****", xmlString);
#endif
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:cleanedData];
    parser.delegate = self;
    [self setUpArrays];
    iStayHealthyVoidExecutionBlock executionBlock = ^{
        [parser parse];
    };
    [self loadData:executionBlock];
}

- (NSData *)validXMLDataForData:(NSData *)xmlData error:(NSError **)error
{
    NSString *xmlString = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    BOOL isValidXML = [CoreXMLTools validateXMLString:xmlString error:error];

    if (isValidXML)
    {
        return xmlData;
    }
    else
    {
        NSData *cleanedXMLData = nil;
        NSString *cleanedString = [CoreXMLTools correctedStringFromString:xmlString];

        isValidXML = [CoreXMLTools validateXMLString:cleanedString error:error];
        if (isValidXML)
        {
            cleanedXMLData = [cleanedString dataUsingEncoding:NSUTF8StringEncoding];
        }
        else
        {
            cleanedXMLData = [kXMLPreamble dataUsingEncoding:NSUTF8StringEncoding];
        }
        return cleanedXMLData;
    }
}

- (void)setUpArrays
{
    self.results = [NSArray array];
    self.medications = [NSArray array];
    self.other = [NSArray array];
    self.procedures = [NSArray array];
    self.previous = [NSArray array];
    self.missed = [NSArray array];
    self.effects = [NSArray array];
    self.contacts = [NSArray array];
    self.wellnesses = [NSArray array];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
#ifdef APPDEBUG
    NSLog(@"START PARSING");
#endif
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSError *saveError = nil;
    PWESPersistentStoreManager *manager = [PWESPersistentStoreManager defaultManager];

    [manager saveContextAndReturnError:&saveError];
    if (nil  != saveError)
    {
#ifdef APPDEBUG
        NSLog(@"END PARSING WITH ERROR");
#endif
        ///TODO handle error after we imported data
    }
    if (self.successBlock)
    {
        BOOL success = (nil == saveError);
        iStayHealthySuccessBlock localBlock = self.successBlock;
        localBlock(success, saveError);
    }
    self.successBlock = nil;
#ifdef APPDEBUG
    NSLog(@"END PARSING");
#endif
}

- (void)   parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
     namespaceURI:(NSString *)namespaceURI
    qualifiedName:(NSString *)qName
       attributes:(NSDictionary *)attributeDict
{
    if (qName)
    {
        elementName = qName;
    }
    if ([elementName isEqualToString:kiStayHealthyRecord])
    {
    }
    PWESPersistentStoreManager *manager = [PWESPersistentStoreManager defaultManager];
    if ([elementName isEqualToString:kResult])
    {
        BOOL exists = [self entryExistsForEntityName:kResults attributes:attributeDict];
        if (!exists)
        {
            Results *results = (Results *) [manager
                                            managedObjectForEntityName:kResults];
            [results importFromDictionary:attributeDict];
        }
    }
    else if ([elementName isEqualToString:kSideEffects])
    {
        BOOL exists = [self entryExistsForEntityName:kSideEffects attributes:attributeDict];
        if (!exists)
        {
            SideEffects *effects = (SideEffects *) [manager
                                                    managedObjectForEntityName:kSideEffects];
            [effects importFromDictionary:attributeDict];
        }
    }
    else if ([elementName isEqualToString:kMedication])
    {
        BOOL exists = [self entryExistsForEntityName:kMedication attributes:attributeDict];
        if (!exists)
        {
            Medication *med = (Medication *) [manager
                                              managedObjectForEntityName:kMedication];
            [med importFromDictionary:attributeDict];
        }
    }
    else if ([elementName isEqualToString:kMissedMedication])
    {
        BOOL exists = [self entryExistsForEntityName:kMissedMedication attributes:attributeDict];
        if (!exists)
        {
            MissedMedication *missedMed = (MissedMedication *) [manager
                                                                managedObjectForEntityName:kMissedMedication];
            [missedMed importFromDictionary:attributeDict];
        }
    }
    else if ([elementName isEqualToString:kOtherMedication])
    {
        BOOL exists = [self entryExistsForEntityName:kOtherMedication attributes:attributeDict];
        if (!exists)
        {
            OtherMedication *otherMed = (OtherMedication *) [manager
                                                             managedObjectForEntityName:kOtherMedication];
            [otherMed importFromDictionary:attributeDict];
        }
    }
    else if ([elementName isEqualToString:kContacts])
    {
        BOOL exists = [self entryExistsForEntityName:kContacts attributes:attributeDict];
        if (!exists)
        {
            Contacts *contacts = (Contacts *) [manager
                                               managedObjectForEntityName:kContacts];
            [contacts importFromDictionary:attributeDict];
        }
    }
    else if ([elementName isEqualToString:kProcedures])
    {
        BOOL exists = [self entryExistsForEntityName:kProcedures attributes:attributeDict];
        if (!exists)
        {
            Procedures *procedures = (Procedures *) [manager
                                                     managedObjectForEntityName:kProcedures];
            [procedures importFromDictionary:attributeDict];
        }
    }
    else if ([elementName isEqualToString:kPreviousMedication])
    {
        BOOL exists = [self entryExistsForEntityName:kPreviousMedication attributes:attributeDict];
        if (!exists)
        {
            PreviousMedication *prevMed = (PreviousMedication *) [manager
                                                                  managedObjectForEntityName:kPreviousMedication];
            [prevMed importFromDictionary:attributeDict];
        }
    }
}

- (BOOL)entryExistsForEntityName:(NSString *)entityName
                      attributes:(NSDictionary *)attributes
{
    __block BOOL exists = NO;

    if ([entityName isEqualToString:kiStayHealthyRecord] && self.masterRecord)
    {
        exists = [self.masterRecord isEqualToDictionary:attributes];
    }
    else if ([entityName isEqualToString:kResults])
    {
        [self.results enumerateObjectsUsingBlock: ^(Results *obj, NSUInteger idx, BOOL *stop) {
             exists = [obj isEqualToDictionary:attributes];
             if (exists)
             {
                 *stop = YES;
             }
         }];
    }
    else if ([entityName isEqualToString:kMedication])
    {
        [self.medications enumerateObjectsUsingBlock: ^(Medication *obj, NSUInteger idx, BOOL *stop) {
             exists = [obj isEqualToDictionary:attributes];
             if (exists)
             {
                 *stop = YES;
             }
         }];
    }
    else if ([entityName isEqualToString:kMissedMedication])
    {
        [self.missed enumerateObjectsUsingBlock: ^(MissedMedication *obj, NSUInteger idx, BOOL *stop) {
             exists = [obj isEqualToDictionary:attributes];
             if (exists)
             {
                 *stop = YES;
             }
         }];
    }
    else if ([entityName isEqualToString:kPreviousMedication])
    {
        [self.previous enumerateObjectsUsingBlock: ^(PreviousMedication *obj, NSUInteger idx, BOOL *stop) {
             exists = [obj isEqualToDictionary:attributes];
             if (exists)
             {
                 *stop = YES;
             }
         }];
    }
    else if ([entityName isEqualToString:kOtherMedication])
    {
        [self.other enumerateObjectsUsingBlock: ^(OtherMedication *obj, NSUInteger idx, BOOL *stop) {
             exists = [obj isEqualToDictionary:attributes];
             if (exists)
             {
                 *stop = YES;
             }
         }];
    }
    else if ([entityName isEqualToString:kProcedures])
    {
        [self.procedures enumerateObjectsUsingBlock: ^(Procedures *obj, NSUInteger idx, BOOL *stop) {
             exists = [obj isEqualToDictionary:attributes];
             if (exists)
             {
                 *stop = YES;
             }
         }];
    }
    else if ([entityName isEqualToString:kSideEffects])
    {
        [self.effects enumerateObjectsUsingBlock: ^(SideEffects *obj, NSUInteger idx, BOOL *stop) {
             exists = [obj isEqualToDictionary:attributes];
             if (exists)
             {
                 *stop = YES;
             }
         }];
    }
    else if ([entityName isEqualToString:kContacts])
    {
        [self.contacts enumerateObjectsUsingBlock: ^(Contacts *obj, NSUInteger idx, BOOL *stop) {
             exists = [obj isEqualToDictionary:attributes];
             if (exists)
             {
                 *stop = YES;
             }
         }];
    }
    return exists;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    ///TODO handle error apart from writing a DEBUG msg
    if (self.successBlock)
    {
        iStayHealthySuccessBlock localBlock = self.successBlock;
        localBlock(NO, parseError);
    }
    self.successBlock = nil;
#ifdef APPDEBUG
    NSLog(@"Error occurred while parsing XML file %@", [parseError localizedDescription]);
#endif
}

- (void)loadData:(iStayHealthyVoidExecutionBlock)executionBlock
{
    PWESPersistentStoreManager *manager = [PWESPersistentStoreManager defaultManager];

    [manager fetchMasterRecord: ^(NSArray *records, NSError *error) {
         if (nil != records && 0 < records.count)
         {
             self.masterRecord = records[0];
         }
         [manager fetchData:kResults predicate:nil sortTerm:kResultsDate ascending:NO completion: ^(NSArray *results, NSError *resultsError) {
              if (nil != results)
              {
                  self.results = results;
              }
              [manager fetchData:kMedication predicate:nil sortTerm:kStartDate ascending:NO completion: ^(NSArray *meds, NSError *medError) {
                   if (nil != meds)
                   {
                       self.medications = meds;
                   }
                   [manager fetchData:kOtherMedication predicate:nil sortTerm:kStartDate ascending:NO completion: ^(NSArray *other, NSError *otherError) {
                        if (nil != other)
                        {
                            self.other = other;
                        }
                        [manager fetchData:kMissedMedication predicate:nil sortTerm:kMissedDate ascending:NO completion: ^(NSArray *missed, NSError *missedError) {
                             if (nil != missed)
                             {
                                 self.missed = missed;
                             }
                             [manager fetchData:kSideEffects predicate:nil sortTerm:kSideEffectDate ascending:NO completion: ^(NSArray *effects, NSError *effectError) {
                                  if (nil != effects)
                                  {
                                      self.effects = effects;
                                  }
                                  [manager fetchData:kPreviousMedication predicate:nil sortTerm:kEndDateLowerCase ascending:NO completion: ^(NSArray *prev, NSError *prevError) {
                                       if (nil != prev)
                                       {
                                           self.previous = prev;
                                       }
                                       [manager fetchData:kProcedures predicate:nil sortTerm:kDate ascending:NO completion: ^(NSArray *procs, NSError *procsError) {
                                            if (nil != procs)
                                            {
                                                self.procedures = procs;
                                            }
                                            [manager fetchData:kContacts predicate:nil sortTerm:kClinicName ascending:YES completion: ^(NSArray *contacts, NSError *contactError) {
                                                 if (nil != contacts)
                                                 {
                                                     self.contacts = contacts;
                                                 }
                                                 if (nil != executionBlock)
                                                 {
                                                     executionBlock();
                                                 }
                                             }];
                                        }];
                                   }];
                              }];
                         }];
                    }];
               }];
          }];
     }];
}

@end
