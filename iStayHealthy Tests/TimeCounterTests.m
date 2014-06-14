//
//  TimeCounterTests.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 14/06/2014.
//
//

#import <XCTest/XCTest.h>
#import "TimeCounter.h"
#import "PWESCalendar.h"

@interface TimeCounter ()
- (void)computeDeltaFromCurrentComponent:(NSDateComponents *)current fireComponent:(NSDateComponents *)fire;
- (void)updateLabelWithTimer:(NSTimer *)timer;
@end

@interface TimeCounterTests : XCTestCase
@end

@implementation TimeCounterTests

- (void)setUp
{
	[super setUp];
}

- (void)tearDown
{
	// Put teardown code here. This method is called after the invocation of each test method in the class.
	[super tearDown];
}

- (void)testComputeDeltaFromComponents
{
	NSDateComponents *now = [[NSDateComponents alloc] init];
	now.hour = 9;
	now.minute = 55;
	now.second = 33;
	now.day = 14;
	now.month = 6;
	now.year = 2014;

	NSDateComponents *fire = [[NSDateComponents alloc] init];
	fire.hour = 15;
	fire.minute = 15;
	fire.second = 23;
	fire.day = 13;
	fire.month = 6;
	fire.year = 2014;
}

@end
