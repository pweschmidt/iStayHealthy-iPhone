//
//  CoreXMLTools.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 03/08/2014.
//
//

#import "CoreXMLTools.h"

@implementation CoreXMLTools

+ (NSString *)cleanedXMLString:(NSString *)string error:(NSError *__autoreleasing *)error
{
	if (nil == string || 0 == string.length)
	{
		return kXMLPreamble; ///empty XML
	}
	NSMutableString *cleanedString = [NSMutableString string];
	NSArray *components = [string componentsSeparatedByString:kXMLPreamble];
	if (2 == components.count) //we should have exactly 2 components
	{
#ifdef APPDEBUG
		NSLog(@"****NOTHING TO CLEAN UP****");
#endif
		return string;
	}

	[cleanedString appendString:kXMLPreamble];
	NSString *restOfXML = components.lastObject;
	NSArray *xmlContentArray = [restOfXML componentsSeparatedByString:kiStayHealthyClosingStatement];
	__block NSString *xmlContentString = nil;
	[xmlContentArray enumerateObjectsUsingBlock: ^(NSString *component, NSUInteger idx, BOOL *stop) {
#ifdef APPDEBUG
	    NSLog(@"Component found %@", component);
#endif
	    NSRange recordRange = [component rangeOfString:kXMLElementRoot];
	    if (recordRange.location != NSNotFound)
	    {
	        xmlContentString = component;
	        *stop = YES;
		}
	}];

	if (nil != xmlContentString)
	{
		[cleanedString appendString:xmlContentString];
		[cleanedString appendString:@"</iStayHealthyRecord>"];
	}

#ifdef APPDEBUG
	NSLog(@"Cleaned up XML string is %@", cleanedString);
#endif
	return (NSString *)cleanedString;
}

+ (BOOL)validateXMLString:(NSString *)xmlString error:(NSError **)error
{
	NSDictionary *userInfo = nil;
	if (nil == xmlString || 0 == xmlString.length)
	{
		userInfo = @{ NSLocalizedDescriptionKey : NSLocalizedString(@"There are no XML data", nil) };
		NSError *innererror = [NSError errorWithDomain:@"com.pweschmidt.istayhealthy"
		                                          code:199
		                                      userInfo:userInfo];
		if (NULL != error)
		{
			*error = innererror;
		}
		return NO;
	}
	NSRange rangeOfPreamble = [xmlString rangeOfString:kXMLPreamble];
	NSRange rangeOfClosingElement = [xmlString rangeOfString:kiStayHealthyClosingStatement];
	NSRange rangeOfStartingElement = [xmlString rangeOfString:kiStayHealthyOpeningStatement];
	if (rangeOfClosingElement.location == NSNotFound || rangeOfPreamble.location == NSNotFound || rangeOfStartingElement.location == NSNotFound)
	{
		userInfo = @{ NSLocalizedDescriptionKey : NSLocalizedString(@"This is not a valid XML string", nil) };
		NSError *innererror = [NSError errorWithDomain:@"com.pweschmidt.istayhealthy"
		                                          code:198
		                                      userInfo:userInfo];
		if (NULL != error)
		{
			*error = innererror;
		}
		return NO;
	}

	NSArray *preambleComponents = [xmlString componentsSeparatedByString:kXMLPreamble];
	NSArray *closingComponents = [xmlString componentsSeparatedByString:kiStayHealthyClosingStatement];
	if (2 == preambleComponents.count && 2 == closingComponents.count)
	{
		return YES;
	}
	else
	{
		userInfo = @{ NSLocalizedDescriptionKey : NSLocalizedString(@"The XML has invalid/duplicated content", nil) };
		NSError *innererror = [NSError errorWithDomain:@"com.pweschmidt.istayhealthy" code:197 userInfo:userInfo];
		if (NULL != error)
		{
			*error = innererror;
		}
		return NO;
	}
}

+ (NSString *)correctedStringFromString:(NSString *)xmlString
{
	if (nil == xmlString || 0 == xmlString.length)
	{
		return kXMLPreamble; ///empty XML
	}
	NSMutableString *string = [NSMutableString string];
	NSArray *endStatements = [xmlString componentsSeparatedByString:kiStayHealthyClosingStatement];
	[string appendString:kXMLPreamble];

	if (nil != endStatements && 1 < endStatements.count)
	{
		NSString *firstComponent = endStatements[0];
		NSArray *xmlStatements = [firstComponent componentsSeparatedByString:kXMLPreamble];
		NSUInteger length = 0;
		NSUInteger index = 0;
		NSUInteger foundIndex = 0;
		for (NSString *xmlComponent in xmlStatements)
		{
			if (xmlComponent.length > length)
			{
				length = xmlComponent.length;
				foundIndex = index;
			}
			index++;
		}

		if (foundIndex < xmlStatements.count)
		{
			NSString *xmlAddedString = xmlStatements[foundIndex];
			[string appendString:xmlAddedString];
			[string appendString:kiStayHealthyClosingStatement];
		}
	}

	return string;
}

@end
