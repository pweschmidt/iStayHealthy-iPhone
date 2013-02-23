//
//  HealthChartsView.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HealthChartsView.h"
#import "ChartSettings.h"
#import "Trafo.h"
#import "ChartEvents.h"
#import "Constants.h"

@implementation HealthChartsView
#pragma mark -
#pragma mark UIView methods

- (void)loadEvents:(NSDictionary *)eventsDictionary
{
    if (nil == self.events)
    {
        self.events = [[ChartEvents alloc] init];
    }
    else
    {
        [self.events.allChartEvents removeAllObjects];
    }
    NSArray *results = [eventsDictionary objectForKey:kResultsData];
    NSArray *meds = [eventsDictionary objectForKey:kMedicationData];
    NSArray *missed = [eventsDictionary objectForKey:kMissedMedicationData];
    
    [self.events loadResult:results];
    [self.events loadMedication:meds];
    [self.events loadMissedMedication:missed];
    [self.events sortEventsAscending:YES];
}

- (id)initWithFrame:(CGRect)frame events:(NSDictionary *)eventsDictionary
{
    self = [self initWithFrame:frame];
    if (nil != self)
    {
        [self loadEvents:eventsDictionary];
    }
    return self;
}


/**
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
		self.backgroundColor = BRIGHT_BACKGROUND;
		self.opaque = YES;
		self.clearsContextBeforeDrawing = YES;
		width = CGRectGetWidth(self.bounds) - MARGINLEFT - MARGINRIGHT;
		height = CGRectGetHeight(self.bounds) - MARGINBOTTOM - MARGINTOP - 5.0;
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
 always draw the co-ordinate system as well as the start/change of medication and
 warning signs for each missed dose
 */
- (void)drawRect:(CGRect)rect
{
    [self drawXAxis:UIGraphicsGetCurrentContext()];
    [self drawYAxis:UIGraphicsGetCurrentContext()];
    [self drawStartAndEndDate:UIGraphicsGetCurrentContext()];
    [self drawMedicationStartLine:UIGraphicsGetCurrentContext()];
    [self drawMissedMedicationWarning:UIGraphicsGetCurrentContext()];
}

/**
 */

#pragma mark -
#pragma mark co-ordinate axes and major ticks on y-axis

/**
 */
- (void)drawXAxis:(CGContextRef)context
{
	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
	CGContextSetLineWidth(context, 2.0);
	CGContextMoveToPoint(context, MARGINLEFT, height+MARGINTOP);
	CGContextAddLineToPoint(context, width , height+MARGINTOP);
	CGContextStrokePath(context);	    
}

/**
 */
- (void)drawYAxis:(CGContextRef)context
{
	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
	CGContextSetLineWidth(context, 2.0);
	CGContextMoveToPoint(context, MARGINLEFT, MARGINTOP);
	CGContextAddLineToPoint(context, MARGINLEFT, height + MARGINTOP);
	CGContextStrokePath(context);    
}

/**
 */
- (void)drawCD4Ticks:(CGContextRef)context
{
	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
	CGContextSetLineWidth(context, TICKWIDTH);
    for (int tick = 1; tick < CD4TICKS ; ++tick)
    {
        float yOffset = [Trafo mapCD4CountToYAxis:(100*tick) forHeight:height];
		CGContextMoveToPoint(context, MARGINLEFT - MAJORTICKLENGTH / 2.0, yOffset);
		CGContextAddLineToPoint(context, MARGINLEFT + MAJORTICKLENGTH / 2.0, yOffset);
		CGContextStrokePath(context);
    }
}

/**
 */
- (void)drawCD4PercentTicks:(CGContextRef)context
{
	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
	CGContextSetLineWidth(context, TICKWIDTH);
    for (int tick = 1; tick < CD4PERCENTTICKS; ++tick)
    {
        float yOffset = [Trafo mapCD4PercentToYAxis:(5*tick) forHeight:height];
		CGContextMoveToPoint(context, MARGINLEFT - MAJORTICKLENGTH / 2.0, yOffset);
		CGContextAddLineToPoint(context, MARGINLEFT + MAJORTICKLENGTH / 2.0, yOffset);
		CGContextStrokePath(context);
    }
}

/**
 */
- (void)drawViralLoadTicks:(CGContextRef)context atOffset:(float)xOffset
{
	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
	CGContextSetLineWidth(context, TICKWIDTH);
    float factor = 10.0;
    for (int tick = 1; tick < VIRALLOADTICKS; ++tick)
    {
        float yOffset = [Trafo mapLogViralLoadToYAxis:factor forHeight:height];
		CGContextMoveToPoint(context, xOffset - MAJORTICKLENGTH / 2.0, yOffset);
		CGContextAddLineToPoint(context, xOffset + MAJORTICKLENGTH / 2.0, yOffset);
		CGContextStrokePath(context);
        factor *= 10.0;
    }
}

#pragma mark -
#pragma mark labels for CD4, CD4% and Viral Loads
/**
 */
- (void)drawCD4Labels:(CGContextRef)context atOffset:(float)xOffset
{
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
	CGContextSelectFont(context, LABELFONTTYPE, LABELFONTSIZESMALL, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode(context, kCGTextStroke);
	for (int tick = 1; tick < CD4TICKS; ++tick)
    {
		int cd4Value = tick * 100;
		if (200 >= cd4Value)
        {
			CGContextSetRGBStrokeColor(context, 0.8, 0.0, 0.0, 1.0);
			CGContextSetRGBFillColor(context, 0.8, 0.0, 0.0, 1.0);
		}
		else if(400 > cd4Value)
        {
			CGContextSetRGBStrokeColor(context, 1.0, 0.4, 0.0, 1.0);
			CGContextSetRGBFillColor(context, 1.0, 0.4, 0.0, 1.0);
		}
		else
        {
			CGContextSetRGBStrokeColor(context, 0.0, 0.4, 0.0, 1.0);
			CGContextSetRGBFillColor(context, 0.0, 0.4, 0.0, 1.0);
		}
        
        
		
		NSString *cd4Label = (tick < (CD4TICKS - 1)) ? [NSString stringWithFormat:@" %d",cd4Value] :
                              [NSString stringWithFormat:@">%d",cd4Value];
		float majorYOffset = [Trafo mapCD4CountToYAxis:cd4Value forHeight:height] - 2.0;
		CGContextShowTextAtPoint(context, xOffset, majorYOffset, [cd4Label UTF8String], [cd4Label length]);
	}
    
}

/**
 */
- (void)drawCD4PercentLabels:(CGContextRef)context atOffset:(float)xOffset
{
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
	CGContextSelectFont(context, LABELFONTTYPE, LABELFONTSIZESMALL, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode(context, kCGTextStroke);
	for (int tick = 1; tick < CD4PERCENTTICKS; ++tick)
    {
		int cd4Value = tick * 5;
		if (15 > cd4Value)
        {
			CGContextSetRGBStrokeColor(context, 0.8, 0.0, 0.0, 1.0);
			CGContextSetRGBFillColor(context, 0.8, 0.0, 0.0, 1.0);
		}
		else if(25 > cd4Value)
        {
			CGContextSetRGBStrokeColor(context, 1.0, 0.4, 0.0, 1.0);
			CGContextSetRGBFillColor(context, 1.0, 0.4, 0.0, 1.0);
		}
		else
        {
			CGContextSetRGBStrokeColor(context, 0.0, 0.4, 0.0, 1.0);
			CGContextSetRGBFillColor(context, 0.0, 0.4, 0.0, 1.0);
		}
        
        
		if ( 0 == ( tick % 2 ))
        {
            NSString *cd4Label = (tick < (CD4PERCENTTICKS - 1)) ? [NSString stringWithFormat:@" %d%%",cd4Value] :
            [NSString stringWithFormat:@">%d%%",cd4Value];
            float majorYOffset = [Trafo mapCD4PercentToYAxis:cd4Value forHeight:height] - 2.0;
            CGContextShowTextAtPoint(context, xOffset, majorYOffset, [cd4Label UTF8String], [cd4Label length]);
        }
	}
    
}

/**
 */
- (void)drawViralLoadLogLabels:(CGContextRef)context atOffset:(float)xOffset
{
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
    float majorYOffset = [Trafo mapLogViralLoadToYAxis:10.0 forHeight:height] - 2.0;
    CGContextSetRGBStrokeColor(context, 0.0, 0.4, 0.0, 1.0);
    CGContextSetRGBFillColor(context, 0.0, 0.4, 0.0, 1.0);
    NSString *undetectedLabel = NSLocalizedString(@"und.", nil);
    CGContextSelectFont(context, LABELSMALLFONTTYPE, LABELFONTSIZESMALL, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(context, kCGTextStroke);
    if (width <= xOffset)
    {
        CGContextShowTextAtPoint(context, xOffset+3.0, majorYOffset, [undetectedLabel UTF8String], [undetectedLabel length]);
    }
    else
    {
        CGContextShowTextAtPoint(context, xOffset/*+MARGINLEFT+3.5*/, majorYOffset, [undetectedLabel UTF8String], [undetectedLabel length]);        
    }
    
    float exponential = 100;
	for (int tick = 2; tick < VIRALLOADTICKS; ++tick)
    {
        majorYOffset = [Trafo mapLogViralLoadToYAxis:exponential forHeight:height] - 2.0;
		if (4 > tick)
        {
			CGContextSetRGBStrokeColor(context, 1.0, 0.4, 0.0, 1.0);
			CGContextSetRGBFillColor(context, 1.0, 0.4, 0.0, 1.0);
		}
		else
        {
			CGContextSetRGBStrokeColor(context, 0.8, 0.0, 0.0, 1.0);
			CGContextSetRGBFillColor(context, 0.8, 0.0, 0.0, 1.0);
		}
        
        
		if (3 >= tick)
        {
			NSString *vlLabel = [NSString stringWithFormat:@"%d",(int)exponential];
			CGContextSelectFont(context, LABELFONTTYPE, LABELFONTSIZESMALL, kCGEncodingMacRoman);
			CGContextSetTextDrawingMode(context, kCGTextStroke);
			CGContextShowTextAtPoint(context, xOffset, majorYOffset, [vlLabel UTF8String], [vlLabel length]);
		}
		else
        {
			NSString *vlLogLabel = @"10";
            if ( (VIRALLOADTICKS - 1) == tick)
            {
                vlLogLabel = @">10";
            }
			NSString *vlExponent = [NSString stringWithFormat:@"%d",tick];
			CGContextSelectFont(context, LABELFONTTYPE, LABELFONTSIZESMALL, kCGEncodingMacRoman);
			CGContextSetTextDrawingMode(context, kCGTextStroke);
			CGContextShowTextAtPoint(context, xOffset, majorYOffset, [vlLogLabel UTF8String], [vlLogLabel length]);
			CGContextSelectFont(context, LABELFONTTYPE, EXPONENTFONTSIZE, kCGEncodingMacRoman);
			CGContextSetTextDrawingMode(context, kCGTextStroke);
			majorYOffset = majorYOffset - 5.0;
            float expOffset = xOffset + 12.0;
            if ( (VIRALLOADTICKS - 1) == tick)
            {
                expOffset = xOffset + 17.5;
            }
			CGContextShowTextAtPoint(context, expOffset, majorYOffset, [vlExponent UTF8String], [vlExponent length]);
		}
        
		exponential *= 10.0;			
	}
    
}
#pragma mark -
#pragma mark data drawing methods

- (void)drawStartAndEndDate:(CGContextRef)context
{
    int count = [self.events.allChartEvents count];
    if (0 == count)
    {
        return;
    }
    float xStart = [Trafo xStart:width forCount:count];
    float xDistance = floorf(width/count);
    int index = 0;
    float xValue = xStart;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMM YY";
    float dateYValue = MARGINTOP + height + 3.0;
    for (ChartEvent *event in self.events.allChartEvents)
    {
        if (0 == index)
        {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xValue - 12.0, dateYValue, 40.0, 10.0)];
            label.text = [formatter stringFromDate:event.date];
            label.font = [UIFont systemFontOfSize:8.0];	
            label.textColor = [UIColor lightGrayColor];
            label.backgroundColor = BRIGHT_BACKGROUND;
            [self addSubview:label];
        }
        else if( 1 <= index && index < count - 1)
        {
            if (event.missedName || event.medicationName)
            {
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xValue - 12.0, dateYValue, 40.0, 10.0)];
                label.text = [formatter stringFromDate:event.date];
                label.font = [UIFont systemFontOfSize:8.0];	
                label.textColor = [UIColor lightGrayColor];
                label.backgroundColor = BRIGHT_BACKGROUND;
                [self addSubview:label];
            }
        }
        else
        {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xValue - 12.0, dateYValue, 40.0, 10.0)];
            label.text = [formatter stringFromDate:event.date];
            label.font = [UIFont systemFontOfSize:8.0];	
            label.textColor = [UIColor lightGrayColor];
            label.backgroundColor = BRIGHT_BACKGROUND;
            [self addSubview:label];
            
        }
        xValue += xDistance;
        index++;
    }    
    
    
    
    
    
}



/**
 plots the CD4 count
 */
- (void)drawCD4Counts:(CGContextRef)context
{
#ifdef APPDEBUG
//    NSLog(@"HealthChartsView::drawCD4Count");
#endif
    int count = [self.events.allChartEvents count];
    if (0 == count)
    {
#ifdef APPDEBUG
//        NSLog(@"HealthChartsView::drawCD4Count events array is empty");
#endif
        return;
    }

    float xStart = [Trafo xStart:width forCount:count];
    float xDistance = floorf(width/count);
#ifdef APPDEBUG
//    NSLog(@"HealthChartsView::drawCD4Count count is %d, width is %f, xStart is %f and distance is %f",count, width, xStart, xDistance);
#endif
    
	CGContextSetLineWidth(context, 1.5);
	CGContextSetRGBStrokeColor(context, 1.0, 0.6, 0.0, 1.0);
	CGContextSetRGBFillColor(context, 1.0, 0.6, 0.0, 1.0);
    
    float xValue = xStart;
    float previousYValue = -99.0;
    float previousXValue = -99.0;
    int point = 0;
    for (ChartEvent *event in self.events.allChartEvents)
    {
        if (event.CD4Count)
        {
            float yValue = [Trafo mapCD4CountToYAxis:[event.CD4Count floatValue] forHeight:height];
            if ( (DATAPOINTSIZE * 2.5) < xDistance)
            {
                CGContextFillRect(context, CGRectMake(xValue - DATAPOINTRADIUS, yValue - DATAPOINTRADIUS, DATAPOINTSIZE, DATAPOINTSIZE));
            }
            if (0.0 < previousYValue)
            {
                CGContextMoveToPoint(context, xValue, yValue);
                CGContextAddLineToPoint(context, previousXValue, previousYValue);
                CGContextStrokePath(context);			
            }
            previousYValue = yValue;
            previousXValue = xValue;
            ++point;
        }
        xValue += xDistance;
    }
    
#ifdef APPDEBUG
//    NSLog(@"HealthChartsView::drawCD4Count we have found %d results",point);
#endif
    
    
}
/**
 plots the CD4%
 */
- (void)drawCD4Percentages:(CGContextRef)context
{
    int count = [self.events.allChartEvents count];
    if (0 == count)
    {
        return;
    }
    
    float xStart = [Trafo xStart:width forCount:count];
    float xDistance = floorf(width/count);
    
	CGContextSetLineWidth(context, 1.5);
	CGContextSetRGBStrokeColor(context, 1.0, 0.6, 0.0, 1.0);
	CGContextSetRGBFillColor(context, 1.0, 0.6, 0.0, 1.0);
    
    float xValue = xStart;
    float previousYValue = -99.0;
    float previousXValue = -99.0;
    for (ChartEvent *event in self.events.allChartEvents)
    {
        if (event.CD4Percent)
        {
            float yValue = [Trafo mapCD4PercentToYAxis:[event.CD4Percent floatValue] forHeight:height];
            if ( (DATAPOINTSIZE * 2.5) < xDistance)
            {
                CGContextFillRect(context, CGRectMake(xValue - DATAPOINTRADIUS, yValue - DATAPOINTRADIUS, DATAPOINTSIZE, DATAPOINTSIZE));
            }
            if (0.0 < previousYValue)
            {
                CGContextMoveToPoint(context, xValue, yValue);
                CGContextAddLineToPoint(context, previousXValue, previousYValue);
                CGContextStrokePath(context);			
            }
            previousYValue = yValue;
            previousXValue = xValue;
        }
        xValue += xDistance;
    }    
}
/**
 plots the log10 viral load values
 */
- (void)drawViralLoadCounts:(CGContextRef)context
{
    int count = [self.events.allChartEvents count];
    if (0 == count)
    {
        return;
    }
    
    float xStart = [Trafo xStart:width forCount:count];
    float xDistance = floorf(width/count);
    
    
	CGContextSetLineWidth(context, 1.5);
	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.4, 1.0);
	CGContextSetRGBFillColor(context, 0.0, 0.0, 0.4, 1.0);
    
    float xValue = xStart;
    float previousYValue = -99.0;
    float previousXValue = -99.0;
    for (ChartEvent *event in self.events.allChartEvents)
    {
        if (event.ViralLoad)
        {
            float yValue = [Trafo mapLogViralLoadToYAxis:[event.ViralLoad floatValue] forHeight:height];
            if ( (DATAPOINTSIZE * 2.5) < xDistance)
            {
                CGContextFillRect(context, CGRectMake(xValue - DATAPOINTRADIUS, yValue - DATAPOINTRADIUS, DATAPOINTSIZE, DATAPOINTSIZE));
            }
            if (0.0 <= previousYValue)
            {
                CGContextMoveToPoint(context, xValue, yValue);
                CGContextAddLineToPoint(context, previousXValue, previousYValue);
                CGContextStrokePath(context);			
            }
            previousYValue = yValue;
            previousXValue = xValue;
        }
        xValue += xDistance;
    }    
    
}

/**
 draws a vertical dashed line at the start/change of medication and an icon indicating the HIV drug taken
 */
- (void)drawMedicationStartLine:(CGContextRef)context
{
#ifdef APPDEBUG
//    NSLog(@"HealthChartsView::drawMedicationStartLine");
#endif
    int count = [self.events.allChartEvents count];
    if (0 == count)
    {
#ifdef APPDEBUG
//        NSLog(@"HealthChartsView::drawMedicationStartLine events array is empty");
#endif
        return;
    }
    
    float xStart = [Trafo xStart:width forCount:count];
    float xDistance = floorf(width/count);
#ifdef APPDEBUG
//    NSLog(@"HealthChartsView::drawMedicationStartLine count is %d, width is %f, xStart is %f and distance is %f",count, width, xStart, xDistance);
#endif
    
    
	CGContextSetLineWidth(context, 1.0);
	CGContextSetLineDash(context, 0, medDashPattern, DASHCOUNT);
	CGContextSetRGBStrokeColor(context, 0.8, 0.8, 0.8, 1.0);
	CGContextSetRGBFillColor(context, 0.8, 0.8, 0.8, 1.0);
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
    
    float xValue = xStart;
    for (ChartEvent *event in self.events.allChartEvents)
    {
        if (event.medicationName)
        {
            CGContextMoveToPoint(context, xValue, MARGINTOP);
            CGContextAddLineToPoint(context, xValue, MARGINTOP + height);
            CGContextStrokePath(context);			
            CGRect frame = CGRectMake(CGRectGetMinX(self.bounds)+xValue - 10.0, CGRectGetMinY(self.bounds)+MARGINTOP + height - 25.0, 20.0, 20.0);
            UILabel *imagelabel = [[UILabel alloc] initWithFrame:frame];
            imagelabel.backgroundColor = BRIGHT_BACKGROUND;
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"combi-label-small.png"]];
            
            [imagelabel addSubview:imageView];
            
            [self addSubview:imagelabel];

        }
        xValue += xDistance;
    }    
	CGContextSetLineDash(context, 0, nil, 0);	
    
}
/**
 draws a warning sign for each missed drug
 */
- (void)drawMissedMedicationWarning:(CGContextRef)context
{
#ifdef APPDEBUG
//    NSLog(@"HealthChartsView::drawMissedMedicationWarning");
#endif
    int count = [self.events.allChartEvents count];
    if (0 == count)
    {
#ifdef APPDEBUG
//        NSLog(@"HealthChartsView::drawMissedMedicationWarning events array is empty");
#endif
        return;
    }
    
    float xStart = [Trafo xStart:width forCount:count];
    float xDistance = floorf(width/count);
    
	CGContextSetLineWidth(context, 1.0);
	CGContextSetLineDash(context, 0, dashPattern, DASHCOUNT);
	CGContextSetRGBStrokeColor(context, 0.8, 0.0, 0.0, 1.0);
	CGContextSetRGBFillColor(context, 0.8, 0.0, 0.0, 1.0);
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
    
    float xValue = xStart;
    for (ChartEvent *event in self.events.allChartEvents)
    {
        if (event.missedName)
        {
            CGContextMoveToPoint(context, xValue, MARGINTOP);
            CGContextAddLineToPoint(context, xValue, MARGINTOP + height);
            CGContextStrokePath(context);	
            CGRect frame = CGRectMake(CGRectGetMinX(self.bounds)+xValue - 10.0, CGRectGetMinY(self.bounds)+MARGINTOP + height - 25.0, 20.0, 20.0);
            UILabel *imagelabel = [[UILabel alloc] initWithFrame:frame];
            imagelabel.backgroundColor = BRIGHT_BACKGROUND;
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"missedsmall.png"]];
            
            [imagelabel addSubview:imageView];
            
            [self addSubview:imagelabel];
        }
        xValue += xDistance;
    }    
	CGContextSetLineDash(context, 0, nil, 0);	
    
}


@end
