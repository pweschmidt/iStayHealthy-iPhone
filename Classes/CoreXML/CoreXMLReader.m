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
#import "CoreXMLTools.h"

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
	[[CoreDataManager sharedInstance] saveContextAndWait:&saveError];
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
	if ([elementName isEqualToString:kResult])
	{
		BOOL exists = [self entryExistsForEntityName:kResults attributes:attributeDict];
		if (!exists)
		{
			Results *results = [[CoreDataManager sharedInstance]
			                    managedObjectForEntityName:kResults];
			[results importFromDictionary:attributeDict];
		}
	}
	else if ([elementName isEqualToString:kSideEffects])
	{
		BOOL exists = [self entryExistsForEntityName:kSideEffects attributes:attributeDict];
		if (!exists)
		{
			SideEffects *effects = [[CoreDataManager sharedInstance]
			                        managedObjectForEntityName:kSideEffects];
			[effects importFromDictionary:attributeDict];
		}
	}
	else if ([elementName isEqualToString:kMedication])
	{
		BOOL exists = [self entryExistsForEntityName:kMedication attributes:attributeDict];
		if (!exists)
		{
			Medication *med = [[CoreDataManager sharedInstance]
			                   managedObjectForEntityName:kMedication];
			[med importFromDictionary:attributeDict];
		}
	}
	else if ([elementName isEqualToString:kMissedMedication])
	{
		BOOL exists = [self entryExistsForEntityName:kMissedMedication attributes:attributeDict];
		if (!exists)
		{
			MissedMedication *missedMed = [[CoreDataManager sharedInstance]
			                               managedObjectForEntityName:kMissedMedication];
			[missedMed importFromDictionary:attributeDict];
		}
	}
	else if ([elementName isEqualToString:kOtherMedication])
	{
		BOOL exists = [self entryExistsForEntityName:kOtherMedication attributes:attributeDict];
		if (!exists)
		{
			OtherMedication *otherMed = [[CoreDataManager sharedInstance]
			                             managedObjectForEntityName:kOtherMedication];
			[otherMed importFromDictionary:attributeDict];
		}
	}
	else if ([elementName isEqualToString:kContacts])
	{
		BOOL exists = [self entryExistsForEntityName:kContacts attributes:attributeDict];
		if (!exists)
		{
			Contacts *contacts = [[CoreDataManager sharedInstance]
			                      managedObjectForEntityName:kContacts];
			[contacts importFromDictionary:attributeDict];
		}
	}
	else if ([elementName isEqualToString:kProcedures])
	{
		BOOL exists = [self entryExistsForEntityName:kProcedures attributes:attributeDict];
		if (!exists)
		{
			Procedures *procedures = [[CoreDataManager sharedInstance]
			                          managedObjectForEntityName:kProcedures];
			[procedures importFromDictionary:attributeDict];
		}
	}
	else if ([elementName isEqualToString:kPreviousMedication])
	{
		BOOL exists = [self entryExistsForEntityName:kPreviousMedication attributes:attributeDict];
		if (!exists)
		{
			PreviousMedication *prevMed = [[CoreDataManager sharedInstance]
			                               managedObjectForEntityName:kPreviousMedication];
			[prevMed importFromDictionary:attributeDict];
		}
	}
//	else if ([elementName isEqualToString:kWellness])
//	{
//        BOOL exists = [self entryExistsForEntityName:kWellness attributes:attributeDict];
//        if (!exists)
//        {
//            Wellness *wellness = [[CoreDataManager sharedInstance]
//                                  managedObjectForEntityName:kWellness];
//            [wellness importFromDictionary:attributeDict];
//        }
//	}
}

- (BOOL)entryExistsForEntityName:(NSString *)entityName
                      attributes:(NSDictionary *)attributes
{
	__block BOOL exists = NO;
	if ([entityName isEqualToString:kResults])
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
#ifdef APPDEBUG
	NSLog(@"Error occurred while parsing XML file %@", [parseError localizedDescription]);
#endif
}

- (void)loadData:(iStayHealthyVoidExecutionBlock)executionBlock
{
	CoreDataManager *dataManager = [CoreDataManager sharedInstance];
	[dataManager fetchiStayHealthyRecordWithCompletion: ^(iStayHealthyRecord *record, NSError *error) {
	    if (nil != record)
	    {
	        self.masterRecord = record;
		}
	    [dataManager fetchDataForEntityName:kResults predicate:nil sortTerm:kResultsDate ascending:NO completion: ^(NSArray *array, NSError *error) {
	        if (nil != array)
	        {
	            self.results = array;
			}
	        [dataManager fetchDataForEntityName:kMedication predicate:nil sortTerm:kStartDate ascending:NO completion: ^(NSArray *array, NSError *error) {
	            if (nil != array)
	            {
	                self.medications = array;
				}
	            [dataManager fetchDataForEntityName:kOtherMedication predicate:nil sortTerm:kStartDate ascending:NO completion: ^(NSArray *array, NSError *error) {
	                if (nil != array)
	                {
	                    self.other = array;
					}
	                [dataManager fetchDataForEntityName:kMissedMedication predicate:nil sortTerm:kMissedDate ascending:NO completion: ^(NSArray *array, NSError *error) {
	                    if (nil != array)
	                    {
	                        self.missed = array;
						}
	                    [dataManager fetchDataForEntityName:kSideEffects predicate:nil sortTerm:kSideEffectDate ascending:NO completion: ^(NSArray *array, NSError *error) {
	                        if (nil != array)
	                        {
	                            self.effects = array;
							}
	                        [dataManager fetchDataForEntityName:kPreviousMedication predicate:nil sortTerm:kEndDateLowerCase ascending:NO completion: ^(NSArray *array, NSError *error) {
	                            if (nil != array)
	                            {
	                                self.previous = array;
								}
	                            [dataManager fetchDataForEntityName:kProcedures predicate:nil sortTerm:kDate ascending:NO completion: ^(NSArray *array, NSError *error) {
	                                if (nil != array)
	                                {
	                                    self.procedures = array;
									}
	                                [dataManager fetchDataForEntityName:kContacts predicate:nil sortTerm:kClinicName ascending:YES completion: ^(NSArray *array, NSError *error) {
	                                    if (nil != array)
	                                    {
	                                        self.contacts = array;
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
