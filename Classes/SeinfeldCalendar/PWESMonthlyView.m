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
#import "SeinfeldCalendar+Handling.h"
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
@property (nonatomic, strong) CALayer *tappedBackgroundLayer;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecogniser;
@property (nonatomic, strong) SeinfeldCalendar *calender;
@property (nonatomic, strong) NSArray *entriesForMonth;
@end

@implementation PWESMonthlyView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		_tappedLayer = nil;
		_tappedBackgroundLayer = nil;
		heightOfEndFrame = frame.size.height;
		_today = [NSDate date];
	}
	return self;
}

+ (PWESMonthlyView *)monthlyViewForCalendar:(SeinfeldCalendar *)calendar
                              seinfeldMonth:(PWESSeinfeldMonth *)seinfeldMonth
                                      frame:(CGRect)frame
{
	PWESMonthlyView *view = [[PWESMonthlyView alloc] initWithFrame:frame];
	view->heightOfEndFrame = 0.f;
	view.exclusiveTouch = YES;
	[view configureViewWithSeinfeldMonth:seinfeldMonth calendar:calendar];
	[view resetFrame];
	return view;
}

- (void)configureViewWithSeinfeldMonth:(PWESSeinfeldMonth *)seinfeldMonth
                              calendar:(SeinfeldCalendar *)calendar
{
	self.calender = calendar;
	self.entriesForMonth = [self entriesForSeinfeldMonth:seinfeldMonth];
	self.seinfeldMonth = seinfeldMonth;

	UITapGestureRecognizer *tapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self
	                                                                                action:@selector(handleTap)];
	[self addGestureRecognizer:tapRecogniser];
	self.tapRecogniser = tapRecogniser;
	self.layers = [NSMutableArray array];
	self.dates = [NSMutableArray array];

	NSString *month = [[PWESCalendar months] objectAtIndex:seinfeldMonth.month - 1];
	CALayer *title = [self monthWithName:[NSString stringWithFormat:@"%@, %ld", month, (long)seinfeldMonth.year]];
	[self.layer addSublayer:title];

	CALayer *header = [self header];
	[self.layer addSublayer:header];


	CGFloat xMargin = 20.0f;
	CGFloat xWidth = (self.bounds.size.width - 40.0f) / 7.0f;
	CGFloat yOffset = 25.f;
	CGFloat weekOffset = header.frame.origin.y + 25.f;
	heightOfEndFrame += yOffset;
	NSInteger currentWeekday = seinfeldMonth.startWeekDay;
	NSInteger daysLeft = seinfeldMonth.totalDays;
	NSInteger startDay = seinfeldMonth.startDay;
	for (NSInteger currentDay = 0; currentDay < daysLeft; ++currentDay)
	{
		NSInteger dayInMonth = startDay + currentDay;
		CGFloat xOffset = (currentWeekday - 1) * xWidth + xMargin;
		NSString *dayString = [NSString stringWithFormat:@"%ld", (long)dayInMonth];
		CATextLayer *dayLayer = [self textLayerWithString:dayString frame:CGRectMake(xOffset, weekOffset, xWidth, 22)];
		[self configureColoursForLayer:dayLayer day:dayInMonth seinfeldMonth:seinfeldMonth];
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

- (CATextLayer *)textLayerWithString:(NSString *)string frame:(CGRect)frame
{
	CATextLayer *dayLayer = [CATextLayer layer];
	dayLayer.string = string;
	dayLayer.font = CTFontCreateWithName((CFStringRef)@"HelveticaNeue-Light", 0.0, NULL);
	dayLayer.alignmentMode = kCAAlignmentCenter;
	dayLayer.fontSize = 20.f;
	dayLayer.frame = frame;
	return dayLayer;
}

- (void)configureColoursForLayer:(CATextLayer *)layer
                             day:(NSInteger)day
                   seinfeldMonth:(PWESSeinfeldMonth *)seinfeldMonth
{
	SeinfeldCalendarEntry *entry = [self calendarEntryForDay:day seinfeldMonth:seinfeldMonth];
	if (nil != entry)
	{
		layer.foregroundColor = [UIColor whiteColor].CGColor;
		layer.font = CTFontCreateWithName((CFStringRef)@"HelveticaNeue-Bold", 0.0, NULL);
		CALayer *backgroundLayer = [CALayer layer];
		backgroundLayer.frame = CGRectMake(layer.frame.origin.x + 4, layer.frame.origin.y + 2, layer.frame.size.width - 8, layer.frame.size.height - 2);
		backgroundLayer.cornerRadius = 5.f;
		backgroundLayer.anchorPoint = layer.anchorPoint;
		if ([entry.hasTakenMeds boolValue])
		{
			backgroundLayer.backgroundColor = DARK_GREEN.CGColor;
		}
		else
		{
			backgroundLayer.backgroundColor = DARK_RED.CGColor;
		}
		[self.layer insertSublayer:backgroundLayer below:layer];
		if ([self isTodayForDay:day month:seinfeldMonth])
		{
			self.tappedBackgroundLayer = backgroundLayer;
		}
	}
	else if ([self isTodayForDay:day month:seinfeldMonth])
	{
		layer.foregroundColor = DARK_RED.CGColor;
	}
	else
	{
		layer.foregroundColor = [UIColor darkGrayColor].CGColor;
	}
}

- (SeinfeldCalendarEntry *)calendarEntryForDay:(NSInteger)day seinfeldMonth:(PWESSeinfeldMonth *)seinfeldMonth
{
	if (nil == self.entriesForMonth)
	{
		return nil;
	}
	__block SeinfeldCalendarEntry *entry = nil;
	[self.entriesForMonth enumerateObjectsUsingBlock: ^(SeinfeldCalendarEntry *obj, NSUInteger idx, BOOL *stop) {
	    NSDateComponents *components = [[PWESCalendar sharedInstance] dateComponentsForDate:obj.date];
	    if (components.day == day && seinfeldMonth.month == components.month && seinfeldMonth.year == components.year)
	    {
	        entry = obj;
	        *stop = YES;
		}
	}];

	return entry;
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
	    layer.foregroundColor = TEXTCOLOUR.CGColor;
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
//	CGPoint superPoint = [self.tapRecogniser locationInView:self.superview];
//	NSLog(@"point hit in view %@ and in superview %@", NSStringFromCGPoint(point), NSStringFromCGPoint(superPoint));
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
//			NSLog(@"***** rectInView = %@ textlayerframe = %@ *****", NSStringFromCGRect(rectInView), NSStringFromCGRect(textLayer.bounds));
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


	NSInteger day = [self.layers indexOfObject:self.tappedLayer] + self.seinfeldMonth.startDay;

	if ([title isEqualToString:@"Yes"])
	{
		[self addBackgroundLayerForDay:day colour:DARK_GREEN tappedLayer:tappedLayer];
		[self createOrUpdateRecordForDay:day hasTakenMeds:YES];
	}
	else if ([title isEqualToString:@"No"])
	{
		[self addBackgroundLayerForDay:day colour:DARK_RED tappedLayer:tappedLayer];
		[self createOrUpdateRecordForDay:day hasTakenMeds:NO];
	}
	NSInteger endDay = self.seinfeldMonth.endDay;
	if (day == endDay && self.seinfeldMonth.isLastMonth)
	{
		[self completeCourse];
	}

	self.tappedLayer = nil;
}

- (void)addBackgroundLayerForDay:(NSInteger)day colour:(UIColor *)colour tappedLayer:(CATextLayer *)tappedLayer
{
	if (self.tappedBackgroundLayer)
	{
		[self.tappedBackgroundLayer removeFromSuperlayer];
		[self.layer setNeedsLayout];
	}
	CALayer *backgroundLayer = [CALayer layer];
	backgroundLayer.frame = CGRectMake(tappedLayer.frame.origin.x + 4, tappedLayer.frame.origin.y + 2, tappedLayer.frame.size.width - 8, tappedLayer.frame.size.height - 2);
	backgroundLayer.cornerRadius = 5.f;
	backgroundLayer.anchorPoint = tappedLayer.anchorPoint;
	backgroundLayer.backgroundColor = colour.CGColor;
	tappedLayer.foregroundColor = [UIColor whiteColor].CGColor;
	tappedLayer.font = CTFontCreateWithName((CFStringRef)@"HelveticaNeue-Bold", 0.0, NULL);
	[self.layer insertSublayer:backgroundLayer below:tappedLayer];
	self.tappedBackgroundLayer = backgroundLayer;
}

- (void)createOrUpdateRecordForDay:(NSInteger)day hasTakenMeds:(BOOL)hasTakenMeds
{
	SeinfeldCalendarEntry *record = [self calendarEntryForDay:day seinfeldMonth:self.seinfeldMonth];
	BOOL recordExists = YES;
	if (nil == record)
	{
		record = [[CoreDataManager sharedInstance] managedObjectForEntityName:kSeinfeldCalendarEntry];
		record.uID = [Utilities GUID];
		recordExists = NO;
	}
	NSDateComponents *components = [[PWESCalendar sharedInstance] dateFromDay:day
	                                                                    month:self.seinfeldMonth.month
	                                                                     year:self.seinfeldMonth.year];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	record.date = [calendar dateFromComponents:components];
	record.hasTakenMeds = [NSNumber numberWithBool:hasTakenMeds];
	[self saveRecord:record recordExists:recordExists];
}

- (void)saveRecord:(SeinfeldCalendarEntry *)record recordExists:(BOOL)recordExists
{
	if (nil == record || nil == self.calender)
	{
		return;
	}
	if (!recordExists)
	{
		[self.calender addEntriesObject:record];
	}
	NSError *error = nil;
	[[CoreDataManager sharedInstance] saveContextAndWait:&error];
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

- (NSArray *)entriesForSeinfeldMonth:(PWESSeinfeldMonth *)seinfeldMonth
{
	__block NSMutableArray *array = [NSMutableArray array];
	NSSet *currentEntries = self.calender.entries;
	if (nil == currentEntries || 0 == currentEntries.count)
	{
		return array;
	}
	NSSortDescriptor *sortDescriptor =
	    [[NSSortDescriptor alloc] initWithKey:kDateLowerCase ascending:YES];
	NSArray *sortedEntries = [currentEntries sortedArrayUsingDescriptors:@[sortDescriptor]];
	[sortedEntries enumerateObjectsUsingBlock: ^(SeinfeldCalendarEntry *entry, NSUInteger idx, BOOL *stop) {
	    NSDateComponents *components = [[PWESCalendar sharedInstance] dateComponentsForDate:entry.date];
	    if (components.month == seinfeldMonth.month && components.year == seinfeldMonth.year)
	    {
	        [array addObject:entry];
		}
	}];
	return array;
}

@end