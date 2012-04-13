//
//  ChartViewLandscape.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChartViewLandscape.h"
#import "ChartSettings.h"
#import "GeneralSettings.h"

@implementation ChartViewLandscape
@synthesize cd4TitleLabel, viralLoadTitleLabel;

/**
 sets up the frame for Landscape mode
 @frame the reference frame to be drawn in
 */
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		maxCD4Value = 700.0;
		maxViralLoadValue = 10000000.0;
		[self setUpCD4Label];
		[self setUpViralLoadLabel];
		isInLandscape = YES;
    }
    return self;
}


#pragma mark -
#pragma mark Labels and Viral Load axis setting

/**
 top label for CD4.
 */
- (void)setUpCD4Label{
	float xValue = CGRectGetMinX(self.bounds) + MARGINLEFT + 40.0;
	float yValue = CGRectGetMinY(self.bounds) + 3.0;
	cd4TitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(xValue, yValue, 50.0, 15.5)];
	cd4TitleLabel.text = @"CD4";
	cd4TitleLabel.textColor = DARK_YELLOW;
	cd4TitleLabel.backgroundColor = BRIGHT_BACKGROUND;
	[self addSubview:cd4TitleLabel];
}

/**
 Top label for Viral load. 
 */
- (void)setUpViralLoadLabel{
	float xValue = CGRectGetMinX(self.bounds) + MARGINLEFT + width - 70.0;
	float yValue = CGRectGetMinY(self.bounds) + 3.0;
	viralLoadTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(xValue, yValue, 50.0, 15.5)];
	viralLoadTitleLabel.text = @"Viral";
	viralLoadTitleLabel.textColor = DARK_BLUE;
	viralLoadTitleLabel.backgroundColor = BRIGHT_BACKGROUND;
	[self addSubview:viralLoadTitleLabel];
}


/**
 when in landscape mode we set up the y-axis for the Viral load on the right side
 @context the graphics context
 */
- (void)setUpYAxisViralLoad:(CGContextRef)context{
	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.4, 1.0);
	CGContextSetRGBFillColor(context, 0.0, 0.0, 0.4, 1.0);
	CGContextSetLineWidth(context, 2.0);
	// x - axis
	CGContextMoveToPoint(context, width, MARGINTOP);
	CGContextAddLineToPoint(context, width, height + MARGINTOP);
	CGContextStrokePath(context);	
	
	CGContextSetLineWidth(context, TICKWIDTH);
	float exponential = 10.0;
	for (int tick = 1; tick <= TICKS; ++tick) {
		float majorYOffset = [self scaledYViralLoadLogValueAsFloat:exponential];
		CGContextMoveToPoint(context, width - MAJORTICKLENGTH / 2.0, majorYOffset);
		CGContextAddLineToPoint(context, width + MAJORTICKLENGTH / 2.0, majorYOffset);
		CGContextStrokePath(context);
		exponential *= 10.0;			
	}
}

#pragma mark -
#pragma mark labelling
/**
labelling for CD4
 @context the graphics context
 */
- (void)setLabelsCD4:(CGContextRef)context{
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
	CGContextSelectFont(context, LABELFONTTYPE, LABELFONTSIZE, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode(context, kCGTextStroke);
	for (int tick = 1; tick <= TICKS; ++tick) {
		int cd4Value = tick * 100;
		if (200 >= cd4Value) {
			CGContextSetRGBStrokeColor(context, 0.8, 0.0, 0.0, 1.0);
			CGContextSetRGBFillColor(context, 0.8, 0.0, 0.0, 1.0);
		}
		else if(400 > cd4Value){
			CGContextSetRGBStrokeColor(context, 1.0, 0.4, 0.0, 1.0);
			CGContextSetRGBFillColor(context, 1.0, 0.4, 0.0, 1.0);
		}
		else {
			CGContextSetRGBStrokeColor(context, 0.0, 0.4, 0.0, 1.0);
			CGContextSetRGBFillColor(context, 0.0, 0.4, 0.0, 1.0);
		}
		
		NSString *cd4Label = [NSString stringWithFormat:@"%d",cd4Value];
		float majorYOffset = [self scaledYCD4ValueAsFloat:(float)cd4Value];
		float xOffset = MARGINLEFT + MAJORTICKLENGTH + 5.0;
		CGContextShowTextAtPoint(context, xOffset, majorYOffset, [cd4Label UTF8String], [cd4Label length]);
	}
}

/**
 labelling for Viral Load
 @context the graphics context
 */
- (void)setLabelsViralLoad:(CGContextRef)context{
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
	float exponential = 10.0;
	for (int tick = 1; tick <= TICKS; ++tick) {
		float xOffset = MARGINLEFT + width - 10.0;
		float majorYOffset = [self scaledYViralLoadLogValueAsFloat:exponential];
		if (3 > tick) {
			CGContextSetRGBStrokeColor(context, 0.0, 0.4, 0.0, 1.0);
			CGContextSetRGBFillColor(context, 0.0, 0.4, 0.0, 1.0);
		}
		else if (6 > tick){
			CGContextSetRGBStrokeColor(context, 1.0, 0.4, 0.0, 1.0);
			CGContextSetRGBFillColor(context, 1.0, 0.4, 0.0, 1.0);
		}
		else {
			CGContextSetRGBStrokeColor(context, 0.8, 0.0, 0.0, 1.0);
			CGContextSetRGBFillColor(context, 0.8, 0.0, 0.0, 1.0);
		}
		
		if (3 > tick) {
			NSString *vlLabel = [NSString stringWithFormat:@"%d",(int)exponential];
			CGContextSelectFont(context, LABELFONTTYPE, LABELFONTSIZESMALL, kCGEncodingMacRoman);
			CGContextSetTextDrawingMode(context, kCGTextStroke);
			CGContextShowTextAtPoint(context, xOffset, majorYOffset, [vlLabel UTF8String], [vlLabel length]);
		}
		else {
			NSString *vlLogLabel = [NSString stringWithFormat:@"10"];
			NSString *vlExponent = [NSString stringWithFormat:@"%d",tick];
			CGContextSelectFont(context, LABELFONTTYPE, LABELFONTSIZE, kCGEncodingMacRoman);
			CGContextSetTextDrawingMode(context, kCGTextStroke);
			CGContextShowTextAtPoint(context, xOffset, majorYOffset, [vlLogLabel UTF8String], [vlLogLabel length]);
			
			CGContextSelectFont(context, LABELFONTTYPE, EXPONENTFONTSIZE, kCGEncodingMacRoman);
			CGContextSetTextDrawingMode(context, kCGTextStroke);
			majorYOffset = majorYOffset - 5.0;
			xOffset = xOffset + 15.0;
			CGContextShowTextAtPoint(context, xOffset, majorYOffset, [vlExponent UTF8String], [vlExponent length]);
		}
		
		exponential *= 10.0;			
	}
}


#pragma mark -
#pragma mark drawRect
/**
 in landscape mode we draw both CD4 and Viral Loads
 @rect 
 */
- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	[self setUpYAxisViralLoad:UIGraphicsGetCurrentContext()];
	[self setLabelsCD4:UIGraphicsGetCurrentContext()];
	[self setLabelsViralLoad:UIGraphicsGetCurrentContext()];
	[super plotCD4Data:UIGraphicsGetCurrentContext()];
	[super plotViralLoadData:UIGraphicsGetCurrentContext()];
}

#pragma mark -
#pragma mark dealloc
/**
 dealloc
 */
- (void)dealloc {
	[cd4TitleLabel release];
	[viralLoadTitleLabel release];
    [super dealloc];
}



@end
