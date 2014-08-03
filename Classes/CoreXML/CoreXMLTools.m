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
		NSLog(@"****NOTHING TO CLEAN UP****");
		return string;
	}

	[cleanedString appendString:kXMLPreamble];
	NSString *restOfXML = components.lastObject;
	NSArray *xmlContentArray = [restOfXML componentsSeparatedByString:@"</iStayHealthyRecord>"];
	__block NSString *xmlContentString = nil;
	[xmlContentArray enumerateObjectsUsingBlock: ^(NSString *component, NSUInteger idx, BOOL *stop) {
	    NSLog(@"Component found %@", component);
	    NSRange recordRange = [component rangeOfString:@"iStayHealthyRecord"];
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

	NSLog(@"Cleaned up XML string is %@", cleanedString);
	return (NSString *)cleanedString;
}

+ (BOOL)validateXMLString:(NSString *)xmlString error:(NSError **)error
{
	NSDictionary *userInfo = nil;
	if (nil == xmlString || 0 == xmlString.length)
	{
		userInfo = @{ NSLocalizedDescriptionKey : NSLocalizedString(@"There are no XML data", nil) };
		NSError *innererror = [NSError errorWithDomain:@"com.pweschmidt.istayhealthy" code:199 userInfo:userInfo];
		if (NULL != error)
		{
			*error = innererror;
		}
		return NO;
	}
	NSRange rangeOfPreamble = [xmlString rangeOfString:kXMLPreamble];
	NSRange rangeOfClosingElement = [xmlString rangeOfString:@"</iStayHealthyRecord>"];
	NSRange rangeOfStartingElement = [xmlString rangeOfString:@"<iStayHealthyRecord"];
	if (rangeOfClosingElement.location == NSNotFound || rangeOfPreamble.location == NSNotFound || rangeOfStartingElement.location == NSNotFound)
	{
		userInfo = @{ NSLocalizedDescriptionKey : NSLocalizedString(@"This is not a valid XML string", nil) };
		NSError *innererror = [NSError errorWithDomain:@"com.pweschmidt.istayhealthy" code:198 userInfo:userInfo];
		if (NULL != error)
		{
			*error = innererror;
		}
		return NO;
	}

	NSArray *preambleComponents = [xmlString componentsSeparatedByString:kXMLPreamble];
	if (2 == preambleComponents.count)
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

@end
