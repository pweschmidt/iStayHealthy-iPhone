//
//  XMLTests.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 03/08/2014.
//
//

#import <XCTest/XCTest.h>
#import "CoreXMLTools.h"


@interface XMLTests : XCTestCase
@property (nonatomic, strong) NSString *normalXML;
@property (nonatomic, strong) NSString *conflictedXML;
@end

@implementation XMLTests

- (void)setUp
{
	[super setUp];
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *normalPath = [bundle pathForResource:@"iStayHealthy.isth" ofType:nil];
	NSString *conflictPath = [bundle pathForResource:@"Conflict.isth" ofType:nil];

	if (nil != normalPath && nil != conflictPath)
	{
		NSData *normalData = [NSData dataWithContentsOfFile:normalPath];
		NSData *conflictData = [NSData dataWithContentsOfFile:conflictPath];
		if (nil != normalData && nil != conflictData)
		{
			NSString *stringNormal = [[NSString alloc] initWithData:normalData encoding:NSUTF8StringEncoding];
			NSString *stringConflict = [[NSString alloc] initWithData:conflictData encoding:NSUTF8StringEncoding];
			self.normalXML = stringNormal;
			self.conflictedXML = stringConflict;
		}
	}
}

- (void)tearDown
{
	[super tearDown];
}

- (void)testCleanXMLStringForNormalXML
{
	NSError *error = nil;
	NSString *cleanedString = [CoreXMLTools cleanedXMLString:self.normalXML error:&error];

	XCTAssertNotNil(cleanedString, @"we should get a cleaned string back");
	XCTAssertNil(error, @"The error should be nil");

	XCTAssertTrue([cleanedString isEqualToString:self.normalXML], @"The cleaned string should be identical to the normal string");
}

- (void)testCleanXMLStringForConflictedXML
{
	NSError *error = nil;
	NSString *cleanedString = [CoreXMLTools cleanedXMLString:self.conflictedXML error:&error];

	XCTAssertNotNil(cleanedString, @"we should get a cleaned string back");
	XCTAssertNil(error, @"The error should be nil");

	BOOL isValid = [CoreXMLTools validateXMLString:cleanedString error:&error];
	XCTAssertTrue(isValid, @"The cleaned string should be a valid XML string");
	XCTAssertNil(error, @"the error should still be nil");
}

- (void)testValidateXMLStringForNormalXML
{
	NSError *error = nil;
	BOOL isValid = [CoreXMLTools validateXMLString:self.normalXML error:&error];
	XCTAssertTrue(isValid, @"the XML string should  be valid");
	XCTAssertNil(error, @"we should not get an error back");
}

- (void)testValidateXMLStringForConflictedXML
{
	NSError *error = nil;
	BOOL isValid = [CoreXMLTools validateXMLString:self.conflictedXML error:&error];
	XCTAssertFalse(isValid, @"the XML string should not be valid");
	XCTAssertNotNil(error, @"we should get an error back");

	if (error)
	{
		XCTAssertTrue(197 == error.code, @"Unexpected error code %ld", (long)error.code);
	}
}

@end
