//
//  PWESMonthlyView.m
//  SeinfeldCalendarWithLayers
//
//  Created by Peter Schmidt on 23/04/2014.
//  Copyright (c) 2014 Peter Schmidt. All rights reserved.
//

#import "PWESMonthlyView.h"
#import "PWESCalendar.h"
#import "PWESSeinfeldMonth.h"
#import "SeinfeldCalendarEntry.h"
#import "PWESResultsDelegate.h"
#import "CoreDataManager.h"
#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

@interface PWESMonthlyView ()
{
	CGFloat heightOfEndFrame;
}
@property (nonatomic, strong) NSDate *today;
@property (nonatomic, strong) PWESSeinfeldMonth *seinfeldMonth;
@property (nonatomic, strong) NSMutableArray *dates;
@property (nonatomic, strong) NSMutableArray *layers;
@property (nonatomic, strong) CATextLayer *tappedLayer;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecogniser;
@end

@implementation PWESMonthlyView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		_tappedLayer = nil;
		heightOfEndFrame = frame.size.height;
		_today = [NSDate date];
	}
	return self;
}

+ (PWESMonthlyView *)monthlyViewWithFrame:(CGRect)monthlyFrame
                            seinfeldMonth:(PWESSeinfeldMonth *)seinfeldMonth
{
	PWESMonthlyView *view = [[PWESMonthlyView alloc] initWithFrame:monthlyFrame];
	view->heightOfEndFrame = 0.f;
	view.exclusiveTouch = YES;
	[view configureViewWithSeinfeldMonth:seinfeldMonth];
	[view resetFrame];
	return view;
}

- (void)configureViewWithSeinfeldMonth:(PWESSeinfeldMonth *)seinfeldMonth
{
	UITapGestureRecognizer *tapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self
	                                                                                action:@selector(handleTap)];
	[self addGestureRecognizer:tapRecogniser];
	self.tapRecogniser = tapRecogniser;
	self.seinfeldMonth = seinfeldMonth;
	self.layers = [NSMutableArray array];
	self.dates = [NSMutableArray array];

	NSString *month = [[PWESCalendar months] objectAtIndex:seinfeldMonth.month - 1];
	CALayer *title = [self monthWithName:month];
	[self.layer addSublayer:title];

	CALayer *header = [self header];
	[self.layer addSublayer:header];


	CGFloat xMargin = 20.0f;
	CGFloat xWidth = (self.bounds.size.width - 40.0f) / 7.0f;
	CGFloat yOffset = 22.f;
	CGFloat weekOffset = header.frame.origin.y + 22.f;
	heightOfEndFrame += yOffset;
	NSInteger currentWeekday = seinfeldMonth.startWeekDay;
	NSInteger daysLeft = seinfeldMonth.totalDays;
	NSInteger startDay = seinfeldMonth.startDay;
	for (NSInteger currentDay = 0; currentDay < daysLeft; ++currentDay)
	{
		NSInteger dayInMonth = startDay + currentDay;
		CGFloat xOffset = (currentWeekday - 1) * xWidth + xMargin;
		CGRect dayFrame = CGRectMake(xOffset, weekOffset, xWidth, 17);
		NSString *dayString = [NSString stringWithFormat:@"%ld", (long)dayInMonth];
		CATextLayer *dayLayer = [CATextLayer layer];
		dayLayer.string = dayString;
		dayLayer.font = CTFontCreateWithName((CFStringRef)@"HelveticaNeue-Light", 0.0, NULL);
		dayLayer.alignmentMode = kCAAlignmentCenter;
		dayLayer.fontSize = 15.f;
		dayLayer.frame = dayFrame;
		if ([self isTodayForDay:dayInMonth month:seinfeldMonth])
		{
			dayLayer.foregroundColor = [UIColor redColor].CGColor;
		}
		else
		{
			dayLayer.foregroundColor = [UIColor darkGrayColor].CGColor;
		}
		[self.layers addObject:dayLayer];
		NSDateComponents *components = [[PWESCalendar sharedInstance] dateFromDay:dayInMonth month:seinfeldMonth.month year:seinfeldMonth.year];
		[self.dates addObject:components];
		[self.layer addSublayer:dayLayer];
		currentWeekday++;
		if (7 < currentWeekday)
		{
			weekOffset += yOffset;
			currentWeekday = 1;
			heightOfEndFrame += yOffset;
		}
	}
}

- (BOOL)isTodayForDay:(NSInteger)day month:(PWESSeinfeldMonth *)month
{
	BOOL isToday = NO;
	NSDateComponents *components = [[PWESCalendar sharedInstance] dateComponentsForDate:self.today];
	if (components.day == day && components.month == month.month && components.year == month.year)
	{
		isToday = YES;
	}
	return isToday;
}

- (BOOL)todayForComponent:(NSDateComponents *)components
{
	BOOL isToday = NO;
	NSDateComponents *todaysComponents = [[PWESCalendar sharedInstance] dateComponentsForDate:self.today];
	if (todaysComponents.day == components.day && todaysComponents.month == components.month && todaysComponents.year == components.year)
	{
		isToday = YES;
	}
	return isToday;
}

- (void)resetFrame
{
	CGRect resetFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, heightOfEndFrame);
	self.frame = resetFrame;
}

- (CALayer *)monthWithName:(NSString *)monthName
{
	CATextLayer *layer = [CATextLayer layer];
	layer.font = CTFontCreateWithName((CFStringRef)@"HelveticaNeue-UltraLight", 0.0, NULL);
	layer.fontSize = 22.f;
	layer.string = monthName;
	layer.alignmentMode = kCAAlignmentLeft;
	layer.frame = CGRectMake(20, 0, self.bounds.size.width - 40, 24);
	layer.foregroundColor = [UIColor darkGrayColor].CGColor;
	heightOfEndFrame += layer.frame.size.height;
	return layer;
}

- (CALayer *)header
{
	CALayer *headerLayer = [CALayer layer];
	CGRect frame = CGRectMake(0, 30, self.bounds.size.width, 22);
	headerLayer.frame = frame;
	headerLayer.backgroundColor = [UIColor clearColor].CGColor;
	CGFloat xMargin = 20.0f;
	CGFloat xWidth = (frame.size.width - 40.0f) / 7.0f;

	NSArray *weekdays = [PWESCalendar weekdays];
	[weekdays enumerateObjectsUsingBlock: ^(NSString *day, NSUInteger index, BOOL *stop) {
	    CATextLayer *layer = [CATextLayer layer];
	    layer.string = day;
	    CGFloat margin = index * xWidth + xMargin;
	    layer.frame = CGRectMake(margin, 0, xWidth, 17);
	    layer.fontSize = 15.f;
	    layer.font = CTFontCreateWithName((CFStringRef)@"HelveticaNeue-Light", 0.0, NULL);
	    layer.foregroundColor = [UIColor blackColor].CGColor;
	    layer.alignmentMode = kCAAlignmentCenter;
	    [headerLayer addSublayer:layer];
	}];

	CALayer *separator = [CALayer layer];
	separator.frame = CGRectMake(15, 20, self.bounds.size.width - 30, 2);
	separator.backgroundColor = [UIColor lightGrayColor].CGColor;

	[headerLayer addSublayer:separator];
	heightOfEndFrame += frame.size.height + 10.f;
	return headerLayer;
}

- (void)handleTap
{
	CGPoint point = [self.tapRecogniser locationInView:self];
	CGPoint superPoint = [self.tapRecogniser locationInView:self.superview];
	NSLog(@"point hit in view %@ and in superview %@", NSStringFromCGPoint(point), NSStringFromCGPoint(superPoint));
	CATextLayer *foundLayer = nil;

	NSUInteger index = 0;
	BOOL canChangeValue = NO;
	for (CATextLayer *textLayer in self.layers)
	{
		CGRect rectInView = [textLayer convertRect:textLayer.frame toLayer:self.layer];
		bool containsPoint = CGRectContainsPoint(rectInView, point);
		bool containsInOtherFrame = CGRectContainsPoint(textLayer.frame, point);
		if (containsPoint || containsInOtherFrame)
		{
			NSLog(@"***** rectInView = %@ textlayerframe = %@ *****", NSStringFromCGRect(rectInView), NSStringFromCGRect(textLayer.bounds));
			foundLayer = textLayer;
			NSDateComponents *components = [self.dates objectAtIndex:index];
			if ([self todayForComponent:components])
			{
				canChangeValue = YES;
			}
			break;
		}
		index++;
	}
	if (nil != foundLayer && canChangeValue)
	{
		self.tappedLayer = foundLayer;
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Meds Taken?" message:@"I have taken my meds today" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", @"No", nil];
		[alertView show];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *title = [alertView buttonTitleAtIndex:buttonIndex];

	if (nil == self.tappedLayer || [title isEqualToString:@"Cancel"])
	{
		return;
	}
	CATextLayer *tappedLayer = self.tappedLayer;
	CALayer *backgroundLayer = [CALayer layer];
	backgroundLayer.frame = CGRectMake(tappedLayer.frame.origin.x + tappedLayer.frame.size.width / 3.5, tappedLayer.frame.origin.y, 17, 17);
	backgroundLayer.cornerRadius = 2.f;
	backgroundLayer.anchorPoint = tappedLayer.anchorPoint;


	SeinfeldCalendarEntry *record = [[CoreDataManager sharedInstance] managedObjectForEntityName:kSeinfeldCalendarEntry];
	NSInteger day = [self.layers indexOfObject:self.tappedLayer] + self.seinfeldMonth.startDay;
	NSInteger month = self.seinfeldMonth.month;
	NSInteger year = self.seinfeldMonth.year;
	record.uID = [Utilities GUID];
	NSDateComponents *components = [[PWESCalendar sharedInstance] dateFromDay:day month:month year:year];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	record.date = [calendar dateFromComponents:components];

	if ([title isEqualToString:@"Yes"])
	{
		backgroundLayer.backgroundColor = [UIColor greenColor].CGColor;
		tappedLayer.foregroundColor = [UIColor blackColor].CGColor;
		record.hasTakenMeds = [NSNumber numberWithBool:YES];
	}
	else if ([title isEqualToString:@"No"])
	{
		backgroundLayer.backgroundColor = [UIColor redColor].CGColor;
		tappedLayer.foregroundColor = [UIColor whiteColor].CGColor;
		record.hasTakenMeds = [NSNumber numberWithBool:NO];
	}
	[self.layer insertSublayer:backgroundLayer below:tappedLayer];
	[self saveRecord:record];
	NSInteger endDay = self.seinfeldMonth.endDay;
	if (day == endDay && self.seinfeldMonth.isLastMonth)
	{
		[self completeCourse];
	}

	self.tappedLayer = nil;
}

- (void)saveRecord:(SeinfeldCalendarEntry *)record
{
	if (nil == record)
	{
		return;
	}
	NSError *error = nil;
	[[CoreDataManager sharedInstance] saveContext:&error];
	__strong id <PWESResultsDelegate> strongDelegate = self.resultsDelegate;
	if (nil != strongDelegate && [strongDelegate respondsToSelector:@selector(updateCalendar)])
	{
		[strongDelegate updateCalendar];
	}
}

- (void)completeCourse
{
	__strong id <PWESResultsDelegate> strongDelegate = self.resultsDelegate;
	if (nil != strongDelegate && [strongDelegate respondsToSelector:@selector(finishCalendar)])
	{
		[strongDelegate finishCalendar];
	}
}

@end
