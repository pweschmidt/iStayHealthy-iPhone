//
//  ChartView.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChartView.h"
#import "Results.h"
#import "Medication.h"
#import "ChartSettings.h"

@implementation ChartView
@synthesize allResults, allMeds, uniqueDates;

/**
 initializes the drawing frame. sets parameters like width, height tickdistance etc required by the chart
 @frame the reference chart frame for the View
 */
- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = BRIGHT_BACKGROUND;
		self.opaque = YES;
		self.clearsContextBeforeDrawing = YES;
		width = CGRectGetWidth(self.bounds) - MARGINRIGHT - MARGINLEFT;
		height = CGRectGetHeight(self.bounds) - MARGINBOTTOM - MARGINTOP;
		tickDistance = [self nearestTickInterval];
		minorTickStart = tickDistance / 2.0;
		maxYValue = tickDistance * TICKS;
		dashPattern[0] = 2.0;
		dashPattern[1] = 3.0;
		medDashPattern[0] = 6.0;
		medDashPattern[1] = 3.0;
		dateDashPattern[0] = 1.0;
		dateDashPattern[1] = 4.0;
		dateDashPattern[2] = 2.5;
	}
    return self;
}

/**
 superclass to set up the x- and y-axes
 @rect the graphics rectangle to be plotted in
 */
- (void)drawRect:(CGRect)rect {
	[self setUpXAxis:UIGraphicsGetCurrentContext()];
	[self setUpYAxis:UIGraphicsGetCurrentContext()];
	[self plotMedLine:UIGraphicsGetCurrentContext()];
}


#pragma mark -
#pragma mark setting up the X/Y axes

/** 
 sets up the x-axis. the x-axis is the timeline.
 @context the graphics context
 */
- (void)setUpXAxis:(CGContextRef)context{
	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
	CGContextSetLineWidth(context, 2.0);
	// x - axis
	CGContextMoveToPoint(context, MARGINLEFT, height+MARGINTOP);
	CGContextAddLineToPoint(context, width, height+MARGINTOP);
	CGContextStrokePath(context);	
}

/**
 sets up the y-axis. this is where the values (CD4/Viral load) are mapped to
 @context the graphics context
 */
- (void)setUpYAxis:(CGContextRef)context{
	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
	CGContextSetLineWidth(context, 2.0);
	CGContextMoveToPoint(context, MARGINLEFT, MARGINTOP);
	CGContextAddLineToPoint(context, MARGINLEFT, height + MARGINTOP);
	CGContextStrokePath(context);	
	
	CGContextSetLineWidth(context, TICKWIDTH);
	for (int tick = 1; tick <= TICKS; ++tick) {
		float majorYOffset = [self scaledYCD4ValueAsFloat:(tick*100)];
		CGContextMoveToPoint(context, MARGINLEFT - MAJORTICKLENGTH / 2.0, majorYOffset);
		CGContextAddLineToPoint(context, MARGINLEFT + MAJORTICKLENGTH / 2.0, majorYOffset);
		CGContextStrokePath(context);
	}
}

#pragma mark -
#pragma mark scaling for CD4 and Viral Load values
/**
 defines the interval between ticks as the nearest integer
 @return float
 */
- (float)nearestTickInterval{
	int iTickHeight = height / TICKS;
	return (float)iTickHeight;
}

/**
 scales CD4 counts to the y-axis. NSNumber as argument
 @cd4Value the CD4 count as NSNumber
 @return float
 */
- (float)scaledYCD4Value:(NSNumber *)cd4Value{
	if (nil == cd4Value) {
		return 0.0;
	}	
	return [self scaledYCD4ValueAsFloat:[cd4Value floatValue]];
}

/**
 scales CD4 counts to the y-axis. float as argument
 @cd4Value the CD4 count as float
 @return float
 */
- (float)scaledYCD4ValueAsFloat:(float)cd4Value{
	float value = cd4Value;
	if (maxCD4Value < value) {
		value = maxCD4Value;
	}
	float yValue = maxYValue * value / maxCD4Value;
	yValue = height + MARGINTOP - yValue;
	return yValue;
}

/**
 scales the log^10 of the viral load to the y-axis. NSNumber as argument
 @viralLoadValue the Viral Load count as NSNumber
 @return float
 */
- (float)scaledYViralLoadLogValue:(NSNumber *)viralLoadValue{
	if (nil == viralLoadValue) {
		return 0.0;
	}
	return [self scaledYViralLoadLogValueAsFloat:[viralLoadValue floatValue]];
}

/**
 scales the log^10 of the viral load to the y-axis. float as argument
 @viralLoadValue the Viral Load count as float
 @return float
 */
- (float)scaledYViralLoadLogValueAsFloat:(float)viralLoadValue{
	if (0.0 == viralLoadValue) {
		viralLoadValue = 1.0;
	}
	if (maxViralLoadValue < viralLoadValue) {
		viralLoadValue = maxViralLoadValue;
	}
	float maxLogValue = log10(maxViralLoadValue);
	float logValue = log10(viralLoadValue);
	float yValue = maxYValue * logValue / maxLogValue;
	yValue = height + MARGINTOP - yValue;
	return yValue;
}

#pragma mark -
#pragma mark plotting
/**
 medline is a vertical line that marks the start date of combi therapy.
 since the timeline on the x-axis is not fixed/linear, the following cases must be considered
 a.) start date is in between existing results. the line will be drawn half way the distance between the 2 result dates
 b.) start date is after the last result or before first result. line will be drawn at the same time point as first/last result
 c.) we haven't got a result yet, meds start straight away. line will be drawn right in the centre.
 
 @context the graphics context to draw on
 */
- (void)plotMedLine:(CGContextRef)context{
	if (nil == allMeds) {
#ifdef APPDEBUG
		NSLog(@"ChartView::plotMedLine allMeds is nil");
#endif
		return;
	}
	int count = [allMeds count];
	if (0 == count) {
#ifdef APPDEBUG
		NSLog(@"ChartView::plotMedLine allMeds is empty");
#endif
		return;
	}
	int resultCount = [allResults count];
	if (0 == resultCount) {
#ifdef APPDEBUG
		NSLog(@"ChartView::plotMedLine allResults is empty");
#endif
		return;
	}
	
	[self findUniqueDates];
	
	
	CGContextSetLineDash(context, 0, medDashPattern, DASHCOUNT);
	CGContextSetRGBStrokeColor(context, 0.8, 0.8, 0.8, 1.0);
	CGContextSetRGBFillColor(context, 0.8, 0.8, 0.8, 1.0);
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
	float startY = MARGINTOP;
	float endY = MARGINTOP + height;
	int startPoint = 0;
	int iXOffset = 0.0;
	if (10 <= resultCount) {
		iXOffset = width / resultCount;
		startPoint = 1;
	}
	else {
		iXOffset = width / (resultCount + 1);
	}
	float xOffset = iXOffset;
	
	for (NSDate *uniqueStartDate in uniqueDates) {
		int resultsPoint = startPoint;
		BOOL hasDrawnLine = NO;
		for (Results *result in allResults) {
#ifdef APPDEBUG
			NSDate *resultsDate = result.ResultsDate;
#endif
			if (!hasDrawnLine && [self startDateIsEarlier:result.ResultsDate medDate:uniqueStartDate]) {
#ifdef APPDEBUG
				NSLog(@"found start date %@ is earlier than results date %@",[uniqueStartDate description],[resultsDate description]);
#endif
				float startX = MARGINLEFT + (resultsPoint * xOffset) - (xOffset/2);
#ifdef APPDEBUG
				NSLog(@"co-ordinates are startX %f, startY %f and endY %f", startX, startY, endY);
#endif
				CGContextMoveToPoint(context, startX, startY);
				CGContextAddLineToPoint(context, startX, endY);
				CGContextStrokePath(context);	
				[self drawMedImage:(startX + 4.0) with:(endY - 25.0)];
				[self drawDate:uniqueStartDate xPosition:startX];
#ifdef APPDEBUG
				NSLog(@"ChartView::plotMedView %f=startX %d=resultsPoint",startX, resultsPoint);
#endif
				
				hasDrawnLine = YES;
			}
			++resultsPoint;
		}
		if (!hasDrawnLine) {
			
			float startX = MARGINLEFT + (resultsPoint * xOffset);
#ifdef APPDEBUG
			NSLog(@"ChartView::plotMedView line not drawn %f=startX %d=resultsPoint",startX, resultsPoint);
#endif
			CGContextMoveToPoint(context, startX, startY);
			CGContextAddLineToPoint(context, startX, endY);
			CGContextStrokePath(context);			
			[self drawMedImage:(startX + 4.0) with:(endY - 25.0)];
			[self drawDate:uniqueStartDate xPosition:startX];
		}
	}

	CGContextSetLineDash(context, 0, nil, 0);	
}

/**
 draws the date as a label below the x-axis
 @date
 @xOffset
 */
- (void)drawDate:(NSDate *)date xPosition:(float)xOffset{
#ifdef APPDEBUG
	NSLog(@"ChartView::drawDate");
#endif
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.dateFormat = @"MMM YY";
	float yValue = MARGINTOP + height + 3.0;
	UILabel *label = [[[UILabel alloc]initWithFrame:CGRectMake(xOffset - 12.0, yValue, 40.0, 10.0)]autorelease];
	label.text = [formatter stringFromDate:date];
	label.font = [UIFont systemFontOfSize:8.0];	
	label.textColor = [UIColor lightGrayColor];
	label.backgroundColor = BRIGHT_BACKGROUND;
	[self addSubview:label];
	
}


/**
 compares dates. returns YES if the resultDate comes after the startDate
 @resultDate
 @startDate
 @return BOOL
 */
- (BOOL)startDateIsEarlier:(NSDate *)resultDate medDate:(NSDate *)startDate{
	return (NSOrderedAscending == [startDate compare:resultDate]);
}

/**
 converts a date into a string with format MM/YY
 @date
 @return NSString
 */
- (NSString *)dateString:(NSDate *)date{
	NSDateFormatter *formatter = [[[NSDateFormatter alloc]init]autorelease];
	formatter.dateFormat = @"MM/YY";
	return [formatter stringFromDate:date];
}

/**
 draws a little picture of a combi pill next to the medline
 @xSize
 @ySize
 */
- (void)drawMedImage:(float)xSize with:(float)ySize{
#ifdef APPDEBUG
	NSLog(@"ChartView::drawMedImage");
#endif	
	CGRect frame = CGRectMake(CGRectGetMinX(self.bounds)+xSize, CGRectGetMinY(self.bounds)+ySize, 20.0, 20.0);
	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	label.backgroundColor = BRIGHT_BACKGROUND;
	UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"combi-label-small.png"]] autorelease];
	[label addSubview:imageView];
	
	[self addSubview:label];
	[label release];
}



/**
 compares the time elapsed between 2 dates. if the difference is within TIMEINTERVAL (defined in ChartSettings.h)
 then it is believed to be within range
 @firstDate 
 @now second date
 */
- (BOOL)isWithinDateRange:(NSDate *)firstDate now:(NSDate *)secondDate{
	NSTimeInterval range = [secondDate timeIntervalSinceDate:firstDate];
#ifdef APPDEBUG
	NSLog(@"time difference is %f",(float)range);
#endif
	if (TIMEINTERVAL >= range) {
		return YES;
	}
	return NO;
}


/**
 runs throug the list of HIV medications and compares the dates.
 If the dates are within 72 hours it is assumed that they start at the same date.
 If beyond, then a separate date will be saved
 */
- (void)findUniqueDates{
	if (nil == allMeds) {
#ifdef APPDEBUG
		NSLog(@"ChartView::findUniqueDates nil == allMeds");
#endif
		return;
	}
	int count = [allMeds count];
	if (0 == count) {
#ifdef APPDEBUG
		NSLog(@"ChartView::findUniqueDates allMeds is empty");
#endif
		return;
	}
	NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithCapacity:0];
	Medication *firstListedMed = (Medication *)[self.allMeds objectAtIndex:0];
	NSDate *date = firstListedMed.StartDate;
	[tmpArray addObject:date];
	if (1 < count) {
		for (int i = 1; i < count; ++i) {
			for (int j = 0; j < i; j++) {
				Medication *iMed = [self.allMeds objectAtIndex:i];
				Medication *jMed = [self.allMeds objectAtIndex:j];
				NSDate *iDate = iMed.StartDate;
				NSDate *jDate = jMed.StartDate;
#ifdef APPDEBUG
				NSLog(@"****** Loop over dates: i=%d , j=%d",i,j);
#endif
				if (![self isWithinDateRange:jDate now:iDate]) {
					[tmpArray addObject:iDate];
				}
			}
		}
		
	}
	self.uniqueDates = tmpArray;
	[tmpArray release];
#ifdef APPDEBUG
	NSLog(@"findUniqueDates has found %d date strings",[self.uniqueDates count]);
#endif
}



/**
 plot the CD4 data with a solid white line
 @context the graphics context
 */
- (void)plotCD4Data:(CGContextRef)context;{
	if (nil == allResults) {
#ifdef APPDEBUG
		NSLog(@"ChartView::plotCD4Data allResults is nil");
#endif
		return;
	}
	int count = [allResults count];
#ifdef APPDEBUG
	NSLog(@"ChartView: plotCD4Data: number of results are %d",count);
#endif
	if (0 == count) {
		return;
	}
	CGContextSetLineWidth(context, 1.5);
	CGContextSetRGBStrokeColor(context, 1.0, 0.6, 0.0, 1.0);
	CGContextSetRGBFillColor(context, 1.0, 0.6, 0.0, 1.0);

	int iXOffset = 0;
	int point = 0;
	int inBetweenLines = 1;
	int start = 0;
	int end = count - 1;
	if (10 > count) {
		iXOffset = width / (count + 1);
		point = 1;
		start = point;
		end = count;
		inBetweenLines = 2;
	}
	else {
		iXOffset = width / count;
	}
	float startX = 0.0;
	float startY = 0.0;
	float xOffset = iXOffset;
	for (Results *result in allResults) {
		NSNumber *cd4Value = result.CD4;
		NSDate *resultsDate = result.ResultsDate;
		float endX = MARGINLEFT + point * xOffset;
		float endY = [self scaledYCD4Value:cd4Value];
		float xValue = endX - DATAPOINTRADIUS;
		float yValue = endY - DATAPOINTRADIUS;
		CGContextFillRect(context, CGRectMake(xValue, yValue, DATAPOINTSIZE, DATAPOINTSIZE));
		if ( inBetweenLines <= point ) {
			CGContextMoveToPoint(context, startX, startY);
			CGContextAddLineToPoint(context, endX, endY);
			CGContextStrokePath(context);			
		}
		if (start == point || end == point) {
			[self drawDate:resultsDate xPosition:endX];
		}
		++point;
		startX = endX;
		startY = endY;
		
	}
	
}


/**
 plotting the viral load data. they will be drawn with a yellow dashed line to distinguish them from
 CD4
 @context the graphics context
*/
- (void)plotViralLoadData:(CGContextRef)context{
	if (nil == allResults) {
#ifdef APPDEBUG
		NSLog(@"ChartView::plotViralLoadData allResults is nil");
#endif
		return;
	}
	int count = [allResults count];
#ifdef APPDEBUG
	NSLog(@"ChartView: plotViralLoadData: number of results are %d",count);
#endif
	if (0 == count) {
		return;
	}
	CGContextSetLineWidth(context, 1.5);
	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.4, 1.0);
	CGContextSetRGBFillColor(context, 0.0, 0.0, 0.4, 1.0);
	int iXOffset = 0;
	int point = 0;
	int inBetweenLines = 1;
	int start = 0;
	int end = count - 1;
	if (10 > count) {
		iXOffset = width / (count + 1);
		point = 1;
		start = point;
		end = count;
		inBetweenLines = 2;
	}
	else {
		iXOffset = width / count;
	}
	float startX = 0.0;
	float startY = 0.0;
	float xOffset = iXOffset;
	for (Results *result in allResults) {
		NSNumber *viralLoadValue = result.ViralLoad;
		NSDate *resultsDate = result.ResultsDate;
		float endX = MARGINLEFT + point * xOffset;
		float endY = [self scaledYViralLoadLogValue:viralLoadValue];
		float xValue = endX - DATAPOINTRADIUS;
		float yValue = endY - DATAPOINTRADIUS;
		CGContextFillEllipseInRect(context, CGRectMake(xValue, yValue, DATAPOINTSIZE, DATAPOINTSIZE));
		if ( inBetweenLines <= point ) {
			CGContextSetLineDash(context, 0, dashPattern, DASHCOUNT);
			CGContextMoveToPoint(context, startX, startY);
			CGContextAddLineToPoint(context, endX, endY);
			CGContextStrokePath(context);			
		}
		if ((start == point || end == point) && !isInLandscape) {
			[self drawDate:resultsDate xPosition:endX];
		}
		++point;
		
		startX = endX;
		startY = endY;
	}
}


#pragma mark -
#pragma mark dealloc
/**
 dealloc
 */
- (void)dealloc {
	[allResults release];
	[allMeds release];
	[uniqueDates release];
    [super dealloc];
}


@end
