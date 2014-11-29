//
//  CoreXMLWriter.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "CoreXMLWriter.h"
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
#import "NSDate+Extras.h"

static NSArray *dataModels()
{
	return @[kResults,
	         kMedication,
	         kMissedMedication,
	         kSideEffects,
	         kContacts,
	         kProcedures,
	         kOtherMedication,
	         kPreviousMedication /*,
	                                kSeinfeldCalendar,
	                                kWellness */];
}

static NSDictionary *elementParentMap()
{
	return @{ kResults : kResults,
			  kMedication : kMedications,
			  kMissedMedication : kMissedMedications,
			  kSideEffects : kHIVSideEffects,
			  kContacts : kClinicalContacts,
			  kProcedures : kIllnessAndProcedures,
			  kOtherMedication : kOtherMedications,
			  kPreviousMedication : kPreviousMedications/*,
		                                                   kSeinfeldCalendar : kSeinfeldCalendars,
		                                                   kWellness : kWellnesses */};
}

static NSDictionary *elementChildMap()
{
	return @{ kResults : kResult,
			  kMedication : kMedication,
			  kMissedMedication : kMissedMedication,
			  kSideEffects : kSideEffects,
			  kContacts : kContacts,
			  kProcedures : kProcedures,
			  kOtherMedication : kOtherMedication,
			  kPreviousMedication : kPreviousMedication,
/*			  kSeinfeldCalendar : kSeinfeldCalendar,
              kWellness : kWellnesses*/};
}

static NSDictionary *sortTerms()
{
	return @{ kResults : kResultsDate,
			  kMedication : kStartDate,
			  kMissedMedication : kMissedDate,
			  kPreviousMedication : kEndDateLowerCase,
			  kSideEffects : kSideEffectDate,
			  kOtherMedication : kStartDate,
			  kProcedures : kDate,
			  kContacts : kClinicName,
/*			  kSeinfeldCalendar : kStartDateLowerCase,
              kWellness : kDateLowerCase */};
}

static NSDictionary *ascendingDictionary()
{
	return @{ kResults: @(1),
			  kMedication : @(1),
			  kMissedMedication : @(1),
			  kPreviousMedication : @(1),
			  kSideEffects : @(1),
			  kOtherMedication : @(1),
			  kProcedures : @(1),
			  kContacts : @(0),
//			  kSeinfeldCalendar : @(1),
//			  kSeinfeldCalendarEntry : @(1),
			  kWellness : @(1) };
}

@interface CoreXMLWriter ()
@property (nonatomic, strong) NSMutableArray *xmlModels;
@property (nonatomic, strong) NSMutableString *xmlString;
@property (nonatomic, assign) NSUInteger insertPosition;
@property (nonatomic, strong) iStayHealthyXMLBlock successBlock;
@end

@implementation CoreXMLWriter
+ (id)sharedInstance
{
	static CoreXMLWriter *reader = nil;
	static dispatch_once_t token;
	dispatch_once(&token, ^{
	    reader = [[CoreXMLWriter alloc] init];
	});
	return reader;
}

- (void)writeWithCompletionBlock:(iStayHealthyXMLBlock)completionBlock
{
	self.successBlock = [completionBlock copy];
	NSString *rootElement = [self rootElementOpen];
	NSUInteger position = [self insertString:rootElement position:0];
	self.insertPosition = position;
	self.xmlModels = [NSMutableArray arrayWithArray:dataModels()];
	NSString *firstModel = [self.xmlModels objectAtIndex:0];
	NSString *nextModel = [self.xmlModels objectAtIndex:1];
	NSString *sortTerm = [sortTerms() objectForKey:firstModel];
	NSNumber *number = [ascendingDictionary() objectForKey:firstModel];
	BOOL ascending = (nil != number && [number boolValue]) ? YES : NO;
    
	[self writeXMLElementForDataModel:firstModel
	                         position:position
	                         sortTerm:sortTerm
	                        ascending:ascending
	                    nextDataModel:nextModel];
}

- (void)writeXMLElementForDataModel:(NSString *)dataModel
                           position:(NSUInteger)position
                           sortTerm:(NSString *)sortTerm
                          ascending:(BOOL)ascending
                      nextDataModel:(NSString *)nextDataModel
{
	[[CoreDataManager sharedInstance] fetchDataForEntityName:dataModel predicate:nil sortTerm:sortTerm ascending:ascending completion: ^(NSArray *array, NSError *error) {
	    if (nil != array)
	    {
	        __block NSUInteger updatedPosition = position;

	        NSString *openElement = [self xmlOpenEnclosingElementForClass:dataModel];
	        [self.xmlString insertString:openElement atIndex:updatedPosition];
	        updatedPosition += openElement.length;
	        [array enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
	            if ([obj respondsToSelector:@selector(xmlString)])
	            {
	                NSString *elementString = [obj xmlString];
	                [self.xmlString insertString:elementString atIndex:updatedPosition];
	                updatedPosition += elementString.length;
				}
			}];
	        NSString *closeElement = [self xmlCloseEnclosingElementForClass:dataModel];
	        [self.xmlString insertString:closeElement atIndex:updatedPosition];
            
	        updatedPosition += closeElement.length;


	        if (nil == nextDataModel) // reached the end
	        {
	            [self.xmlString insertString:[self rootElementClose] atIndex:updatedPosition];
	            if (nil != self.successBlock)
	            {
	                self.successBlock(self.xmlString, nil);
				}
			}
	        else
	        {
	            NSUInteger index = [self.xmlModels indexOfObject:nextDataModel] + 1;
	            NSString *nextModel = nil;
	            if (self.xmlModels.count > index)
	            {
	                nextModel = [self.xmlModels objectAtIndex:index];
				}
	            NSString *sortTerm = [sortTerms() objectForKey:nextDataModel];
	            NSNumber *number = [ascendingDictionary() objectForKey:nextDataModel];
	            BOOL ascending = (nil != number && [number boolValue]) ? YES : NO;
	            [self writeXMLElementForDataModel:nextDataModel
	                                     position:updatedPosition
	                                     sortTerm:sortTerm
	                                    ascending:ascending
	                                nextDataModel:nextModel];
			}
		}
	    else
	    {
	        if (nil != self.successBlock)
	        {
	            self.successBlock(nil, error);
			}
		}
	}];
}

- (NSUInteger)insertString:(NSString *)string position:(NSUInteger)position
{
	if (nil == self.xmlString)
	{
		self.xmlString = [NSMutableString string];
	}
	if (nil != string)
	{
		[self.xmlString insertString:string atIndex:position];
	}
	return self.xmlString.length;
}

- (NSString *)rootElementOpen
{
	NSMutableString *string = [NSMutableString string];
	[string appendString:kXMLPreamble];
	[string appendString:@"\r"];
	[string appendString:[NSString stringWithFormat:@"<%@ ", kXMLElementRoot]];
	NSString *dbVersion = [NSString stringWithFormat:@" dbVersion=\"%@\"", kXMLDBVersionString];
	[string appendString:dbVersion];
	[string appendString:@" fromDevice=\"iOS\""];
	NSDate *date = [NSDate date];
	NSString *fromDate = [NSString stringWithFormat:@" fromDate=\"%@\"", [date stringFromCustomDate]];
	[string appendString:fromDate];
	[string appendString:@">"];
	return string;
}

- (NSString *)rootElementClose
{
	return @"</iStayHealthyRecord>";
}

- (NSString *)xmlOpenEnclosingElementForClass:(NSString *)className
{
	NSString *mappedParentName = [elementParentMap() objectForKey:className];
	if (nil == mappedParentName)
	{
		return [NSString stringWithFormat:@"<Unknown>"];
	}
	else
	{
		return [NSString stringWithFormat:@"<%@>", mappedParentName];
	}
//	if ([className isEqualToString:kResults])
//	{
//		return [NSString stringWithFormat:@"<%@>", kResults];
//	}
//	else if ([className isEqualToString:kSideEffects])
//	{
//		return [NSString stringWithFormat:@"<%@>", kHIVSideEffects];
//	}
//	else if ([className isEqualToString:kMedication])
//	{
//		return [NSString stringWithFormat:@"<%@>", kMedications];
//	}
//	else if ([className isEqualToString:kOtherMedication])
//	{
//		return [NSString stringWithFormat:@"<%@>", kOtherMedications];
//	}
//	else if ([className isEqualToString:kPreviousMedication])
//	{
//		return [NSString stringWithFormat:@"<%@>", kPreviousMedications];
//	}
//	else if ([className isEqualToString:kMissedMedication])
//	{
//		return [NSString stringWithFormat:@"<%@>", kMissedMedications];
//	}
//	else if ([className isEqualToString:kContacts])
//	{
//		return [NSString stringWithFormat:@"<%@>", kClinicalContacts];
//	}
//	else if ([className isEqualToString:kProcedures])
//	{
//		return [NSString stringWithFormat:@"<%@>", kIllnessAndProcedures];
//	}
//	else if ([className isEqualToString:kSeinfeldCalendar])
//	{
//		return [NSString stringWithFormat:@"<%@>", kSeinfeldCalendars];
//	}
//	else if ([className isEqualToString:kSeinfeldCalendarEntry])
//	{
//		return [NSString stringWithFormat:@"<%@>", kSeinfeldCalendarEntry];
//	}
//	else if ([className isEqualToString:kWellness])
//	{
//		return [NSString stringWithFormat:@"<%@>", kWellnesses];
//	}
	return nil;
}

- (NSString *)xmlCloseEnclosingElementForClass:(NSString *)className
{
	NSString *mappedParentName = [elementParentMap() objectForKey:className];
	if (nil == mappedParentName)
	{
		return [NSString stringWithFormat:@"</Unknown>"];
	}
	else
	{
		return [NSString stringWithFormat:@"</%@>", mappedParentName];
	}
//	if ([className isEqualToString:kResults])
//	{
//		return [NSString stringWithFormat:@"</%@>", kResults];
//	}
//	else if ([className isEqualToString:kSideEffects])
//	{
//		return [NSString stringWithFormat:@"</%@>", kHIVSideEffects];
//	}
//	else if ([className isEqualToString:kMedication])
//	{
//		return [NSString stringWithFormat:@"</%@>", kMedications];
//	}
//	else if ([className isEqualToString:kOtherMedication])
//	{
//		return [NSString stringWithFormat:@"</%@>", kOtherMedications];
//	}
//	else if ([className isEqualToString:kPreviousMedication])
//	{
//		return [NSString stringWithFormat:@"</%@>", kPreviousMedications];
//	}
//	else if ([className isEqualToString:kMissedMedication])
//	{
//		return [NSString stringWithFormat:@"</%@>", kMissedMedications];
//	}
//	else if ([className isEqualToString:kContacts])
//	{
//		return [NSString stringWithFormat:@"</%@>", kClinicalContacts];
//	}
//	else if ([className isEqualToString:kProcedures])
//	{
//		return [NSString stringWithFormat:@"</%@>", kIllnessAndProcedures];
//	}
//	else if ([className isEqualToString:kSeinfeldCalendar])
//	{
//		return [NSString stringWithFormat:@"</%@>", kSeinfeldCalendars];
//	}
//	else if ([className isEqualToString:kSeinfeldCalendarEntry])
//	{
//		return [NSString stringWithFormat:@"</%@>", kSeinfeldCalendarEntry];
//	}
//	else if ([className isEqualToString:kWellness])
//	{
//		return [NSString stringWithFormat:@"</%@>", kWellnesses];
//	}
	return nil;
}

@end
